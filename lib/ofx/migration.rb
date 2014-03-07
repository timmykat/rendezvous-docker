module Ofx
  class Migration
  
    # Instance variables
    #   @type (str):            The type of migration, whether 'minutes' or 'standards' 
    #   @index_url (str):       Initial page to look for migration source (read from ofx_config.yml)
    #     - minutes:              The index page lists links to each set of minutes
    #     - standards:            The standards discussion is on the index page, with links to each change
    #   @src_doc (NXD)          The Nokogiri::XML::Document that is the source
    #   @src_sub_docs (arr)     An array of XML objects that will become content instances
    #   @to_doc (NXD)           The Nokogiri::XML::Document that is the XML structure of the information to be migrated 
    #                             - This includes multiple types of information
  
    attr_accessor :type, :base_url, :index_url, :src_doc, :src_sub_docs, :to_doc
    
    include Ofx
    
    def self.new(*args, &block)
      obj = allocate
      obj.send(:initialize, *args, &block)

      obj
    end
    
    def initialize(type)
      return nil if ! %w(minutes standards).include? type
      @type = type
      @base_url = Rails.configuration.ofx[:migration][:base_url]
      @index_url = "#{@base_url}#{Rails.configuration.ofx[:migration][:index][type]}"
    end
    
# -- PULL methods for retrieving information from the old site
    def pull
      @src_doc = Nokogiri::XML(open(@index_url), &:noblanks).clean_docuwiki
      @src_sub_docs = []
      @to_doc = Nokogiri::XML::Document.new
      @to_doc.root = @to_doc.create_element('migration')
      @to_doc.root['type'] = @type
      
      send("pull_#{@type}".to_sym)

      xsl = Nokogiri::XSLT(File.read("#{File.dirname(__FILE__)}/assets/pretty_print.xsl"))
  
      File.open("#{Rails.root}/tmp/migration_#{@type}.xml", 'w') { |f| f.write(xsl.apply_to(@to_doc).to_s) }
    end
    
    # - Minutes migration methods ------------------------------
    def pull_minutes
      @src_doc.css('h2').each do |meeting_type|
        meeting_type.next.css('li a').each do |link|
          @src_sub_docs << Nokogiri::XML(open("#{@base_url}#{link.attributes['href'].value}"), &:noblanks).clean_docuwiki
          process_minute
        end
      end
    end
    
    def process_minute    
      # Set up the _to_ doc which holds the migrated information
      @to_doc.root.add_child('<minute></minute>')
      minute_node = @to_doc.root.last_element_child
      /^(?<meeting_type>[a-z]+)_(?<year>[a-z0-9]+)_[a-z]+$/ =~ @src_sub_docs.last.at_css('h1').attributes['id'].value
      meeting_type = /dir/.match(meeting_type) ?  'dirm' : 'agm'
      minute_node << "<year>#{year}</year>" << "<meeting_type>}</meeting_type>" 
      send("build_#{meeting_type}".to_sym, minute_node)
    end

    def build_agm(minute_node)
      minute_node['type'] = 'agm'
      
      # Each h2 starts off a new section, which corresponds to a column in the minutes table
      # Loop over them
      doc = @src_sub_docs.last
      doc.css('h2').each do |section|
        case section.attributes['id'].value
          when 'date'
            /^(?<day>\d{1,2})\w+ (?<month>[a-zA-Z]+),?\s*(?<year>\d{4})/ =~ section.next_element.content.strip 
            puts "#{doc.at_css('h1').content} | #{day}-#{month[0..2]}-#{year}"
            minute_node << "<date>#{day}-#{month[0..2]}-#{year}</date>"
          when 'location'
            minute_node << "<location>#{section.next.content.strip}</location>"
            
          # Attendees have 2 sections: members and observers
          when 'attendees'
            section.next_element.css('h3').each do |h3|
              if /members/.match(h3.attributes['id'].value)
                minute_node << "<members>\n#{h3.next}\n</members>"
              elsif /observing/.match(h3.attributes['id'].value)
                minute_node << "<observing>\n#{h3.next}\n</observing>"
              end
            end
          when 'minutes'        
            minute_node.add_child("<minutes></minutes>")
            node = section.next
            until node.nil? or (node.comment? and node.content.strip == 'wikipage stop')
              minute_node.last_element_child << node if /[a-z]/.match(node.content)
              node = node.next
            end
        end
      end
    end
    
    def build_dirm(minute_node)
      minute_node['type'] = 'dirm'
      
      # Each h2 starts off a new section, which corresponds to a column in the minutes table
      # Loop over them
      doc = @src_sub_docs.last
      doc.css('h2').each do |section|
        case section.attributes['id'].value
          when 'date'
            /(?<day>\d{1,2})\w+ (?<month>[a-zA-Z]+),?\s*(?<year>\d{4})/ =~ section.next.content.strip
            puts "#{doc.at_css('h1').content} | #{day}-#{month[0..2]}-#{year}"
            minute_node << "<date>#{day}-#{month[0..2]}-#{year}</date>"
          when 'location'
            minute_node << "<location>#{section.next.content.strip}</location>"
          when 'attendees'
            minute_node << "<members>#{section.next}</members>"
          when 'minutes'
            minute_node.add_child("<minutes></minutes>")
            node = section.next
            until node.nil? or (node.comment? and node.content.strip == 'wikipage stop')
              minute_node.last_element_child << node if /[a-z]/.match(node.content)
              node = node.next
            end
        end
      end
    end
        
    # - Standards migration methods ------------------------------
    def pull_standards
      version = ''
      status = 'approved'
      type = 'minor'
      
      # Need to set standard_node because it's otherwise it's local within the case statement
      node_list = @src_doc.css('body > *')
      node = node_list.shift
      h2_seen = false
      until node.name == 'hr'
        if node.name == 'h2'
          h2_seen = true
          section = node.attributes['id'].value
           if /major.*v2/.match(section)
            version = '2.0'
            @to_doc.root << ('<standard></standard>')
            standard_node = @to_doc.root.last_element_child
            standard_node['version'] =  version
            status = 'proposed'
            type = 'major'
            node = node_list.shift
            puts "V #{version}"

          elsif /committee/.match(section)    
            # The committee starts off each new version except 2.0
            @to_doc.root << ('<standard></standard>')
            standard_node = @to_doc.root.last_element_child
            /(?<version_from_page>\d\.\d)/ =~ node.content
            version = version_from_page
            standard_node['version'] =  version
            committee_node = standard_node.add_child('<committee></committee>').first
            node = node_list.shift
            committee_node.children = node
            node = node_list.shift
            puts "V #{version} committee"

          elsif /(?<change_type>major|minor).*disc/ =~ section
            status = 'proposed'
            type = change_type
            node = node_list.shift
            puts "V #{version} discussion"

          # The following all correspond to sections that present a list of links to changes
          elsif /change/.match(section)
            /(?<status>approved|withdrawn|proposed)/ =~ section
            status ||= 'approved'
            type = 'minor'
            puts "V #{version} change"
          end
        end
        if h2_seen
          if node.name == 'ul' and !node.css('li a').blank?
            node.css('li a').each do |link|
              @src_sub_docs << Nokogiri::XML(open("#{@base_url}#{link.attributes['href'].value}"), &:noblanks).clean_docuwiki
              standard_node.add_child(process_standard_change)
              # standard_node.add_child("<change>#{link.content}</change>")
              standard_node.last_element_child['status'] = status
              standard_node.last_element_child['type'] = type
            end
          else
            standard_node << node if ! %w(h2 h3 p).include? node.name
          end
        end
        node = node_list.shift 
      end    
    end
    
    def process_standard_change
      change_node = @to_doc.last_element_child.add_child("<change></change>").first
      
      # Build the node
      node_list = @src_sub_docs.last.css('body > *')
      node = node_list.first
      h2_seen = false
      until node.nil? or node.name == 'hr'
        
        if node.name == 'h1'
          title = node.content.strip
          puts "Processing: #{title}"
          change_node << "<title>#{title}</title>"
        end

        if node.name == 'h2'
          h2_seen = true
          section = node.attributes['id'].value
          if section == 'status'
            change_node << '<final_status></final_status>'
          elsif section == 'overview'
            change_node << '<overview></overview>'
          elsif /(solution|implementation)/.match(section)
            change_node << '<solution></solution>'
          elsif %w(comments caveats discussion).include? section
            change_node << '<comments></comments>'
          else
            change_node << '<discussion></discussion>'
            change_node.last_element_child << '<discussion_heading>#{node.content.strip}</discussion_heading>'
          end
          node = node_list.shift
        end
        node.content = node.content.strip if node.name == 'p'
        change_node.last_element_child << node if h2_seen
        node = node_list.shift
      end
      change_node
    end

# -- PUSH methods for retrieving information from the old site
    def push(clean = false)
    
      # Initialize
      if clean
        case @type
          when 'minutes'
            Minute.destroy_all
          when 'standards'
            StandardChange.destroy_all
        end
      end
      @xml = Nokogiri::XML(open("#{Rails.root}/tmp/migration_#{@type}.xml", &:noblanks)) 
      @xml.root.children.each do |node|
        send("build_#{@type}".to_sym, node)
      end
    end
    
    
    def build_minutes(node)
      if node.name == 'minute'
        m = Minute.new
        m.meeting = node.attributes['type'].value
        m.published = true
        node.children.each do |data|
          m.location  = data.inner_text if data.name == 'location'
          m.members   = data.inner_html if data.name == 'members'
          m.observing = data.inner_html if data.name == 'observing'
          m.minutes   = data.inner_html if data.name == 'minutes'
        end
        if !m.save
          puts m.errors
        end
      end      
    end
    
    def build_standards(node)
      if node.name == 'standard'
        v = Version.new
        version = node.attributes['version'].value
        v.version = version
        v.status = version.to_f <= 1.3 ? 'approved' : 'pending'
        v.current = version == '1.3'
        s = StandardChange.new
        node.children.each do |data|
          v.committee       = data.inner_html if data.name == 'committee'
          s.status          = data.attributes['status'].value
          s.type            = data.attributes['type'].value
          s.status_details  = data.inner_html if data.name == 'final_status'
          s.overview        = data.inner_html if data.name == 'overview'
          s.solution        = data.inner_html if data.name == 'solution'
          v.discussion      = data.inner_html if data.name == 'discussion'
          comments          = data.inner_html if data.name == 'comments'
        end
        if !v.save
          put "VERSION problem:"
          puts v.errors
        else
          s.version = v
          s.comment = comments
          if !s.save
            puts "STANDARD problem:"
            puts s.errors
          end
        end
      end      
    end       
  end  
end

class Nokogiri::XML::Document    
  def clean_docuwiki
  
    # Remove header, aside, and table of contents
    self.at_css('#dokuwiki__header').remove if !self.at_css('#dokuwiki__header').blank?
    self.at_css('#dokuwiki__aside').remove if !self.at_css('#dokuwiki__aside').blank?
    self.at_css('#dw__toc').remove if !self.at_css('dw__toc').blank?
    self.traverse do |node|
      if node.children.length > 0
        node.traverse do |child|
          node = check_enclosure(child)
        end 
      else
        node = check_enclosure(node)
      end
    end
    self
  end

  def check_enclosure(node)
    if node.name == 'div'
      node.replace(node.children)
    end
    node.remove_attribute('class')
  end
end

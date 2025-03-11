module MarkdownConcern 
  extend  ActiveSupport::Concern

  included do    
    def self.markdown_attributes(*attrs)
      attrs.each do |attr|
        define_method("#{attr}_as_html") do
          as_html(attr)
        end
      end
    end

    def as_html(attribute)
      text = send(attribute)
      return '' if text.blank?
  
      renderer = Redcarpet::Render::HTML.new
      markdown = Redcarpet::Markdown.new(renderer)

      # Need to handle line breaks with backslash
      markdown.render(text).gsub("\\", "<br />").html_safe
    end
  end
end
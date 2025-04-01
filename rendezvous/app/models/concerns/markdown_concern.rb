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
      return needs_content(attribute) if text.blank?
  
      renderer = Redcarpet::Render::HTML.new
      markdown = Redcarpet::Markdown.new(renderer)

      # Need to handle line breaks with backslash
      markdown.render(text).gsub("\\", "<br />").html_safe
    end

    def needs_content(key)
      if key.nil?
        "<p style='background-color: red; color: white'>This content needs to be created.</p>".html_safe
      elsif !Rails.env.production?
        "<p style='background-color: red; color: white'>The content for <em>#{key}</em> needs to be created.</p>".html_safe
      end
    end

  end
end
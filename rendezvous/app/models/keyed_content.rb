class KeyedContent < ApplicationRecord
  include MarkdownConcern

  markdown_attributes :content

  module ClassMethods
    def content_keys    
      [
        "main_welcome",
        "main_other_accommodations",
        "main_volunteers",
        "main_vendors",
        "main_history",
        "page_legal",
        "page_history"     
      ]
    end
  end

  extend ClassMethods
end

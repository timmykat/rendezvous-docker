# == Schema Information
#
# Table name: keyed_contents
#
#  id         :bigint           not null, primary key
#  content    :text(65535)
#  key        :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_keyed_contents_on_key  (key) UNIQUE
#
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

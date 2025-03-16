class KeyedContent < ApplicationRecord
  include MarkdownConcern

  markdown_attributes :content
end

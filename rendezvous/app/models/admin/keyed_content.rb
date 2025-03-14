class Admin::KeyedContent < ApplicationRecord
  include MarkdownConcern

  markdown_attributes :content
end

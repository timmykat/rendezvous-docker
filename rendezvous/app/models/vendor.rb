class Vendor < ApplicationRecord
  include MarkdownConcern

  markdown_attributes :address
end

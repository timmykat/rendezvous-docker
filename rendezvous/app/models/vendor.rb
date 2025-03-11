class Vendor < ApplicationRecord
  include MarkdownConcern
  markdown_attributes :address

  include RailsSortable::Model
  set_sortable :order

  validates :name, presence: true
end

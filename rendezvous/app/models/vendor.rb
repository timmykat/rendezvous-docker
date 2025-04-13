class Vendor < ApplicationRecord
  include MarkdownConcern
  markdown_attributes :address

  belongs_to :owner, class_name: 'User', optional: true

  include RailsSortable::Model
  set_sortable :order

  include SortingConcern

  validates :name, presence: true
end

class Faq < ApplicationRecord

  include MarkdownConcern
  markdown_attributes :question, :response

  include RailsSortable::Model
  set_sortable :order

  include SortingConcern

  validates :question, presence: true
end

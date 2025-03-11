class Admin::Faq < ApplicationRecord

  include MarkdownConcern
  markdown_attributes :question, :response
  
  include RailsSortable::Model
  set_sortable :order

  validates :question, presence: true
end

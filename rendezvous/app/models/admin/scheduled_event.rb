class Admin::ScheduledEvent < ApplicationRecord
  belongs_to :venue, optional: true

  include MarkdownConcern
  markdown_attributes :short_description, :long_description

  include RailsSortable::Model
  set_sortable :order

  include SortingConcern

  validates :name, presence: true
  validates :time, presence: true
end

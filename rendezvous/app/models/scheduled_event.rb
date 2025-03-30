class ScheduledEvent < ApplicationRecord
  belongs_to :venue, optional: true

  include MarkdownConcern
  markdown_attributes :short_description, :long_description

  include RailsSortable::Model
  set_sortable :order

  include SortingConcern

  belongs_to :main_event, class_name: 'ScheduledEvent', optional: true
  has_many :sub_events, class_name: 'ScheduledEvent', foreign_key: 'main_event_id', dependent: :nullify

  validates :name, presence: true
  validates :time, presence: true
end

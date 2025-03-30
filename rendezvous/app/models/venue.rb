class Venue < ApplicationRecord
  include MarkdownConcern

  has_many :scheduled_events
  
  attribute :event_hotel, :boolean, default: false
  attribute :show_field_venue, :boolean, default: false

  validates :name, presence: true
  
  markdown_attributes :address, :details
end

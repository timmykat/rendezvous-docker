class Admin::Venue < ApplicationRecord
  has_many :scheduled_events
  
  attribute :event_hotel, :boolean, default: false
  attribute :show_field_venue, :boolean, default: false

  validates :name, presence: true
end

# == Schema Information
#
# Table name: venues
#
#  id               :bigint           not null, primary key
#  address          :text(65535)
#  close_date       :date
#  details          :text(65535)
#  email            :string(255)
#  group_code       :string(255)
#  name             :string(255)
#  phone            :string(255)
#  reservation_url  :string(255)
#  rooms_available  :integer
#  show_field_venue :boolean
#  type             :string(255)
#  website          :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_venues_on_show_field_venue  (show_field_venue)
#
class Venue < ApplicationRecord
  include MarkdownConcern

  has_many :scheduled_events
  
  attribute :event_hotel, :boolean, default: false
  attribute :show_field_venue, :boolean, default: false

  validates :name, presence: true
  
  markdown_attributes :address, :details
end

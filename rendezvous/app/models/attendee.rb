# == Schema Information
#
# Table name: attendees
#
#  id              :integer          not null, primary key
#  attendee_age    :string(255)      default("adult")
#  name            :string(255)
#  sunday_dinner   :boolean
#  volunteer       :boolean
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  registration_id :integer
#
# Indexes
#
#  index_attendees_on_attendee_age   (attendee_age)
#  index_attendees_on_sunday_dinner  (sunday_dinner)
#  index_attendees_on_volunteer      (volunteer)
#
class Attendee < ApplicationRecord
  include StripWhitespace
  
  belongs_to :registration, class_name: 'Event::Registration'

  before_validation :normalize_age
  
  validates :name, presence: true
  validates :attendee_age, inclusion: { in: ['adult', 'youth', 'child'] } 
  
  def self.sunday_dinner_count
    Attendee.where(sunday_dinner: true).count
  end
  
  def self.volunteer_count
    Attendee.where(volunteer: true).count
  end
  
  def self.adult_count
    Attendee.where(attendee_age: 'adult').count
  end

  def self.youth_count
    Attendee.where(attendee_age: 'youth').count
  end
  
  def self.child_count
    Attendee.where(attendee_age: 'child').count
  end

  def normalize_age
    self.attendee_age = 'adult' if self.attendee_age == 'senior'
  end
end

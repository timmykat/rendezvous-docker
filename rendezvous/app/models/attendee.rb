class Attendee < ApplicationRecord
  include StripWhitespace
  
  belongs_to :registration, class_name: 'Event::Registration'

  before_validation :normalize_age
  
  validates :name, presence: true
  validates :attendee_age, inclusion: { in: ['adult', 'senior', 'child'] } 
  
  def self.sunday_dinner_count
    Attendee.where(sunday_dinner: true).count
  end
  
  def self.volunteer_count
    Attendee.where(volunteer: true).count
  end
  
  def self.adult_count
    Attendee.where(attendee_age: 'adult').count
  end
  
  def self.child_count
    Attendee.where(attendee_age: 'child').count
  end

  def normalize_age
    self.attendee_age = 'adult' if self.attendee_age == 'senior'
  end
end

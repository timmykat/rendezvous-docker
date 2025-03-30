class Attendee < ApplicationRecord
  belongs_to :registration, class_name: 'Event::Registration'
  
  validates :name, presence: true
  validates :attendee_age, inclusion: { in: ['adult', 'child'] } 
  
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
end

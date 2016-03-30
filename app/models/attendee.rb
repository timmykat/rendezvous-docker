class Attendee < ActiveRecord::Base
  belongs_to :rendezvous_registration
  
  validates :name, :presence => true
  validates :adult_or_child, :inclusion => { :in => ['adult', 'child'] } 
  
  def self.sunday_dinner_count
    Attendee.where(:sunday_dinner => true).count
  end
  
  def self.volunteer_count
    Attendee.where(:volunteer => true).count
  end
  
  def self.adult_count
    Attendee.where(:adult_or_child => 'adult').count
  end
  
  def self.child_count
    Attendee.where(:adult_or_child => 'child').count
  end
end

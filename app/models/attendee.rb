class Attendee < ActiveRecord::Base
  belongs_to :rendezvous_registration
  
  validates :name, :presence => true
  validates :adult_or_child, :inclusion => { :in => ['adult', 'child'] } 
end

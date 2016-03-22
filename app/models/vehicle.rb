class Vehicle < ActiveRecord::Base

  belongs_to :user
  
  validates :year, :inclusion => { :in => (1919..2015).map{ |int| int.to_s }, :message => "%{value} is not a valid year" }      
end
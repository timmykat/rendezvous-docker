class Vehicle < ActiveRecord::Base

  belongs_to :user
  has_many :registrations_vehicles, class_name: 'RegistrationsVehicles', foreign_key: :vehicle_id
  has_many :registrations, class_name: 'Event::Registration', through: :registrations_vehicles
  
  validates :year, inclusion: { in: (1919..2015).map{ |int| int.to_s }, message: "%{value} is not a valid year" }
  validates :marque, presence: true
  
  def full_spec
    "#{year} #{marque} #{model}  <br /><em>Judging category: #{judging_category}</em>".html_safe
  end
  
  def year_marque_model
    "#{year} #{marque} #{model} "
  end
  
  def judging_category
    category = ''
        
    if %W(Panhard Peugeot Renault).include? @marque
      category == 'Other French'
    elsif marque == 'Citroen'
      case model
      when /(c2|traction)/i
        category = 'C2 / Traction Avant'
      when /D \(\w+\)/
        category = 'ID / DS'
      when /2CV/
        category = '2CV / Truckette'
      when /SM/
        category = 'SM'
      when /CX/
        category = 'CX /  CXA'
      when /(Ami|Dyane|Mehari|Visa)/
        category = 'Ami / Dyane / Mehari / Visa'
      when /(GS|GSA|XM|Xantia|C6|H-Van)/
        category = 'GS / GSA / XM / Xantia / C6 / H-Van'
      end
    elsif !model.blank? && !marque.blank?
      category = 'Non-French'
    end
    category
  end  
  
  def at_event?(registration)
    registrations.each do |r|
      if r == registration
        return true
      end
    end
    return false
  end
end
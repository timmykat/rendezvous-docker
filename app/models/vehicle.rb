class Vehicle < ActiveRecord::Base

  belongs_to :user
  
  validates :year, :inclusion => { :in => (1919..2015).map{ |int| int.to_s }, :message => "%{value} is not a valid year" }
  validates :marque, :presence => true
  
  def full_spec
    "#{year} #{marque} #{model}  <br />new(<em>Judging category: #{judging_category}</em>".html_safe
  end
  
  def judging_category
    category = ''
        
    if %W(Panhard Peugeot Renault).include? @arque
      category == 'Other French'
    elsif marque == 'Citroen'
      case model
      when /traction/i
        category = 'Traction Avant'
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
end
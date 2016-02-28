class Vehicle < ActiveRecord::Base

  belongs_to :user
  
  validates :year, :inclusion => { :in => (1919..2015).map{ |int| int.to_s }}
  
  validate :marque_must_exist, :model_must_exist
  
  def marque_must_exist
    if marque == 'Other' && !other_marque.present?
      errors.add(:other_marque, 'should be specified')
    end 
  end
  
  def model_must_exist
    if model == 'Other' && !other_model.present?
      errors.add(:other_model, 'should be specified')
    end 
  end
  
  def self.marques
    ['Citroën', 'Panhard', 'Peugeot', 'Renault', 'Other']
  end
  
  def self.models
    ['Traction Avant (11)',
     'Traction Avant (15)', 
     '2CV (sedan)', 
     '2CV (truckette)', 
     'Dyane', 
     'D (early)', 
     'D (late)', 
     'D (wagon)', 
     'D (Chapron)', 
     'SM', 
     'CX (series 1)',
     'CX (series 2)',
     'Other'
    ]
  end
  
  def full_spec
    year.to_s + " " + ((marque == 'Other' || marque.blank?) ? other_marque : marque) + " " + ((model == 'Other' || model.blank?) ? other_model : model)
  end
end
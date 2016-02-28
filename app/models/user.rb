class User < ActiveRecord::Base

  include RoleModel
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, :omniauth_providers => [:facebook, :twitter]
         
  has_one :avatar

  has_many :pictures
  has_many :vehicles
  has_many :rendezvous_registrations
  
  validates :first_name, :presence => true
  validates :last_name, :presence => true
  validates:email, :format => { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: :create }
  validates :address1, :presence => true
  validates :city, :presence => true
  validates :state_or_province, :presence => true
  
  # US or Canadian postal code
  validates :postal_code, :presence => true, :format => { :with => /\A((\d{5})(-\d{4})?)|(\w\d\w\s?\d\w\d)\z/}
  
  accepts_nested_attributes_for :pictures, allow_destroy: true
  accepts_nested_attributes_for :vehicles, allow_destroy: true, :reject_if => lambda { |a| (a[:marque].blank? && a[:other_marque].blank?) || (a[:model].blank? && a[:other_model].blank?) }
  
  roles :admin, :organizer, :registrant

  # Handle omniauth signin
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
#      user.name = auth.info.name   # assuming the user model has a name
    end
  end

  def display_name
    if self.first_name
      if self.last_name
        return "#{self.first_name} #{self.last_name}"
      else 
        return self.first_name
      end
    elsif self.last_name
      return self.last_name
    else
      return self.email
    end
  end
  
end

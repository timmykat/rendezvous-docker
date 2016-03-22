class User < ActiveRecord::Base

  include RoleModel
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
#          :omniauthable, :omniauth_providers => [:facebook, :twitter]
         
  has_one :avatar

  has_many :pictures, :dependent => :destroy
  has_many :vehicles, :dependent => :destroy
  has_many :rendezvous_registrations
  has_many :authorizations
  
  validates :first_name, :presence => true
  validates :last_name, :presence => true
  validates :email, :format => { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }
  validates :address1, :presence => true, :on => :update
  validates :city, :presence => true, :on => :update
  validates :state_or_province, :presence => true, :on => :update
#   validates :password, :length => { :in => 6..20 }
  
  # US or Canadian postal code
  validates :postal_code, :presence => true, :format => { :with => /\A((\d{5})(-\d{4})?)|(\w\d\w\s?\d\w\d)\z/}, :on => :update
  
  # Password policy
  validate :password_complexity
  
  accepts_nested_attributes_for :pictures, allow_destroy: true
  accepts_nested_attributes_for :vehicles, allow_destroy: true, :reject_if => lambda { |v| ( v[:marque].blank? || v[:model].blank? || v[:year].blank? ) }
  
  roles :admin, :organizer, :registrant
    
  def password_complexity
    if password.present?
      lower = password.match(/[a-z]/)
      upper = password.match(/[A-Z]/)
      digit = password.match(/[0-9]/)
      unless lower && upper && digit
        errors.add :password, "must include 1 of each: lower case letter, upper case letter, digit"
      end
    end
  end

  # Handle omniauth signin
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.provider = auth.provider
      user.email    = auth.info.email
      user.password = Devise.friendly_token[0,20]
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

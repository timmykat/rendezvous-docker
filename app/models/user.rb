class User < ActiveRecord::Base

  include RoleModel
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, :omniauth_providers => [:facebook, :twitter]
         
  has_one :avatar

  has_many :pictures
  accepts_nested_attributes_for :pictures, allow_destroy: true
  
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

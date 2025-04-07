require 'devise/models/linkable'
require 'devise/models/token_authenticatable'
require 'role_model'

class User < ApplicationRecord

  include RoleModel
  include StripWhitespace

  before_save :set_country

  attr_accessor :role

  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  include Devise::Models::TokenAuthenticatable

  has_many :pictures, dependent: :destroy
  has_many :vehicles, dependent: :destroy
  has_many :registrations, class_name: 'Event::Registration'
  has_many :authorizations
  has_one  :vendor

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }, presence: true
  validates :address1, presence: true, on: :update, allow_blank: true
  validates :city, presence: true, on: :update, allow_blank: true
#   validates :password, length: { in: 6..20 }

  # US or Canadian postal code
  validate :postal_code_by_country, on: :update

  # Password policy
  validate :password_complexity

  default_scope { order(last_name: :asc) }

  scope :with_current_registration, -> {
    joins(:registrations)
      .where('registrations.year = ?', Date.current.year)
      .select('users.*')
      .distinct
  }

  scope :with_registrations, -> {
    joins(:registrations)
      .group('users.id')
      .having('COUNT(registrations.id) > 0')
      .select('users.*')
  }

  accepts_nested_attributes_for :pictures, allow_destroy: true
  accepts_nested_attributes_for :vehicles, allow_destroy: true, reject_if: lambda { |v| ( v[:marque].blank? || v[:model].blank? || v[:year].blank? ) }

  roles :admin, :organizer, :registrant, :tester, :superuser, :vendor

  def password_complexity
    if password.present?
      lower = password.match(/[a-z]/)
      upper = password.match(/[A-Z]/)
      digit = password.match(/[0-9]/)
      unless lower && upper && digit
        errors.add :password, "must include 1 of each: lower case letter, upper case letter, number"
      end
    end
  end

  def newbie?
    self.registrations.length == 1 && self.registrations.first.created_at.year == Date.current.year
  end

  def postal_code_by_country
    if Rails.configuration.rendezvous[:provinces].include? (state_or_province)
      country_format = 'Canadian'
      valid = /\A(\w\d\w\s?\d\w\d)\z/.match(postal_code)
    elsif !state_or_province.blank?
      country_format = 'US'
      valid = /\A((\d{5})(-\d{4})?)\z/.match(postal_code)
    else
      valid = true
    end

    errors.add :postal_code, "does not appear to be consistent with #{country_format} format" unless valid
  end

  def set_country
    if Rails.configuration.rendezvous[:provinces].include? (state_or_province)
      country = 'CA'
    elsif !state_or_province.blank?
      country = 'US'
    else
      country = 'Other'
    end
  end

  # Handle omniauth signin
  # def self.from_omniauth(auth)
  #   where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
  #     user.provider = auth.provider
  #     user.email    = auth.info.email
  #     user.password = Devise.friendly_token[0,20]
  #   end
  # end

  def full_name
    "#{first_name} #{last_name}"
  end
  alias_method :display_name, :full_name

  def last_name_first
    "#{last_name}, #{first_name}"
  end

  def current_registration
    self.registrations.where(year: Date.current.year).first
  end

  def attending
    !current_registration.blank?
  end

  def country_name
    if Rails.configuration.rendezvous[:countries].map{ |code, name| code.to_s }.include? country
      Rails.configuration.rendezvous[:countries][country.to_sym]
    else
      ''
    end
  end

  def self.find_by_token(token)
    User.where(login_token: token).first
  end

  def self.with_role role
    mask = User.mask_for role
    User.where('roles_mask & ? > 0', mask)
  end
end

# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  address1               :string(255)
#  address2               :string(255)
#  citroenvie             :boolean
#  city                   :string(255)
#  country                :string(255)
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  first_name             :string(255)
#  is_admin_created       :boolean          default(FALSE)
#  is_testing             :boolean          default(FALSE)
#  last_active            :datetime
#  last_name              :string(255)
#  login_token            :string(255)
#  login_token_sent_at    :datetime
#  postal_code            :string(255)
#  provider               :string(255)
#  recaptcha_whitelisted  :boolean
#  receive_mailings       :boolean          default(TRUE)
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string(255)
#  role_mask              :integer
#  roles_mask             :integer
#  state_or_province      :string(255)
#  uid                    :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_citroenvie            (citroenvie)
#  index_users_on_country               (country)
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_first_name            (first_name)
#  index_users_on_last_active           (last_active)
#  index_users_on_last_name             (last_name)
#  index_users_on_login_token           (login_token) UNIQUE
#  index_users_on_provider              (provider)
#  index_users_on_receive_mailings      (receive_mailings)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_roles_mask            (roles_mask)
#  index_users_on_state_or_province     (state_or_province)
#  index_users_on_uid                   (uid)
#
require 'devise/models/linkable'
require 'devise/models/token_authenticatable'
require 'role_model'

class User < ApplicationRecord

  include RoleModel
  include StripWhitespace

  before_save :set_country

  attr_accessor :role
  attr_accessor :current_registration_id

  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  include Devise::Models::TokenAuthenticatable


  has_many :pictures, dependent: :destroy
  has_many :vehicles, dependent: :destroy
  has_many :registrations, class_name: 'Event::Registration', inverse_of: :user
  has_many :authorizations
  has_one  :vendor, foreign_key: :owner_id
  has_many :donations
  has_many :square_transactions

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }, presence: true
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

  def generate_password
    password = (65 + rand(26)).chr + 6.times.inject(''){|a, b| a + (97 + rand(26)).chr} + (48 + rand(10)).chr
    self.password = password
    self.password_confirmation = password
  end

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
    if Rails.configuration.geodata[:provinces].include? (state_or_province)
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
    if Rails.configuration.geodata[:provinces].include? (state_or_province)
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
    self.registrations.current.first
  end

  def attending
    !current_registration.blank?
  end

  def country_name
    if Rails.configuration.geodata[:countries].map{ |code, name| code.to_s }.include? country
      Rails.configuration.geodata[:countries][country.to_sym]
    else
      ''
    end
  end

  def self.find_by_token(login_token)
    digest = Devise.token_generator.digest(User, :login_token, login_token)
    User.where(login_token: digest).first
  end

  def self.with_role role
    mask = User.mask_for role
    User.where('roles_mask & ? > 0', mask)
  end

  def generate_email_address
    tag = generate_tag
    if last_name
      username = "#{last_name}_#{tag}"
    else
      username = "user_#{tag}"
    end

    self.email = "#{username}@citroenrendezvous.org"
  end

  # Override of Devise method to use sidekiq
  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  private
    def generate_tag(length = 4)
      chars = %w[A C D E F G H J K L M N P Q R T U V W X Y Z 1 2 3 4 5 6 7 8 9] # User friendly characters
      Array.new(length) { chars.sample }.join
    end
end

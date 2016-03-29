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
    
  def full_name
    "#{first_name} #{last_name}"
  end
  alias_method :display_name, :full_name
  
  def last_name_first
    "#{last_name}, #{first_name}"
  end
  
  def attending
    !self.rendezvous_registrations.where(:year => Time.now.year).blank?
  end
  
  def self.mailchimp_init_request
    gibbon = Gibbon::Request.new  #(:api_key => Rails.configuration.rendezvous[:mailchimp][:api_key]) 
    gibbon.timeout = 10
    gibbon
  end
  
  def self.synchronize_with_mailchimp_data
    gibbon = User.mailchimp_init_request
    list_id = Rails.configuration.rendezvous[:mailchimp][:list][:list_id]
    
    # Get list data from Mailchimp
    begin
      subscriber_list = gibbon.lists(list_id).members.retrieve( :params => { :fields => 'members.email_address,members.status', :count => "1000" } )

      subscriber_emails = subscriber_list['members'].reduce([]) { |subscriber_emails, s| 
        subscriber_emails << s['email_address'] if s['status'] == 'subscribed' 
        subscriber_emails
      }
    
      user_list = {}
      User.all.each do |u|
        init = u.receive_mailings
        u.receive_mailings = subscriber_emails.include?(u.email)
        u.save(:validate => false) unless (u.receive_mailings == init)
        user_list[u.email] = u.receive_mailings? ? 'subscribed' : 'not subscribed'
      end
      response = {
        :status => :ok,
        :user_list => user_list
      }
    rescue Gibbon::MailChimpError => e
      response = {
        :status => :error,
        :message => "MailChimp Error: #{e.details}"
      }
    end
    response
  end
  
  def mailchimp_action(action)
  
    gibbon = User.mailchimp_init_request
    list_id = Rails.configuration.rendezvous[:mailchimp][:list][:list_id]
    
    require 'digest'
    hashed_email = Digest::MD5.hexdigest email.downcase
    
    case action
      when 'get_status'
        begin
          member = gibbon.lists(list_id).members(hashed_email).retrieve
          response = {
            :status => :ok,
            :member_status => member['status'],
          }
        rescue Gibbon::MailChimpError => e
          if e.body['status'] == 404
            response = {
              :status => :not_found,
              :message => "That user is not in the list."
            }            
          else
            response = {
              :status => :error,
              :message => "MailChimp Error: #{e.detail}"
            }
          end
        end
        
      when 'subscribe'
        begin
          # MMERGE3 ==> Thinking about coming to the Rendezvous 2016 'Yes', 'No', 'Maybe'
          hashed_email = Digest::MD5.hexdigest email.downcase
          gibbon.lists(list_id).members(hashed_email).upsert( :body => { :email_address => email, :status => 'subscribed', :merge_fields => { :FNAME => first_name, :LNAME => last_name, :MMERGE3 => 'Yes' }} )
          receive_mailings = true
          self.save(:validate => false)
           response = {
            :status => :ok,
            :member_status => 'subscribed',
          }
        rescue Gibbon::MailChimpError => e
          response = {
            :status => :error,
            :message => "MailChimp Error: #{e.detail}"
          }
        end
        
      when 'unsubscribe'
        # First have to check to see if the member exists
        begin
          member = gibbon.lists(list_id).members(hashed_email).retrieve
        rescue Gibbon::MailChimpError => e
          if e.body['status'] == 404
            response = {
              :status => :ok,
              :member_status => 'unsubscribed',
            }
            return response           
          end
        end
          
        begin
          gibbon.lists(list_id).members(hashed_email).update( :body => { :status => 'unsubscribed' } )
          receive_mailings = false
          self.save!
           response = {
            :status => :ok,
            :member_status => 'unsubscribed',
          }
        rescue Gibbon::MailChimpError => e
          response = {
            :status => :error,
            :message => "MailChimp Error: #{e.detail}"
          }
        end
    end 
    response
  end
end

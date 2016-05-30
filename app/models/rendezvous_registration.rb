class RendezvousRegistration < ActiveRecord::Base
  
  belongs_to :user
  has_many :attendees, :dependent => :destroy
  has_many :transactions, :dependent => :destroy
  
  accepts_nested_attributes_for :user
  accepts_nested_attributes_for :attendees, :allow_destroy => true
  accepts_nested_attributes_for :transactions, :allow_destroy => true
  
  scope :current, -> { where(:year => Time.now.year) }
  
  validate :minimum_number_of_adults
  validate :payment
  validates :paid_method, :inclusion => { :in => Rails.configuration.rendezvous[:payment_methods] }, :allow_blank => true
  validates :invoice_number, :uniqueness => true, :format => { :with => /\ARR20\d{2}-\d{3,4}\z/, :on => :new }, :allow_blank => true
  
  validates :status, :inclusion => { :in => Rails.configuration.rendezvous[:registration_statuses] }
  
  serialize :events, JSON
  
  def minimum_number_of_adults
    if (number_of_adults < 1) 
      errors.add_to_base "You must register at least one adult."
    end
  end
  
  def payment
    if !paid_amount.nil?
      if (paid_amount.to_f > total.to_f)
        errors.add_to_base "The paid amount is more than the owed amount."
      end
    end
  end
  
  def amount_due
    total.to_f - paid_amount.to_f
  end
  
  def self.invoice_number
    prefix = "CR#{Time.now.year}-"
    previous_code = RendezvousRegistration.pluck(:invoice_number).last
    if previous_code.blank?
      next_number = 101
    else 
      next_number = previous_code.match(/#{prefix}(\d+)/)[1].to_i + 1
    end
    "#{prefix}#{next_number}"
  end
end

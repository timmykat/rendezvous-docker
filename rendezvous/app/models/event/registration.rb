
module Event
  class Registration < ApplicationRecord

    include AdminCreatable
    
    belongs_to :user
    has_many :attendees, dependent: :destroy
    has_many :transactions, class_name: 'SquareTransaction', dependent: :destroy
    has_many :registrations_vehicles, class_name: 'RegistrationsVehicles', foreign_key: :registration_id, dependent: :destroy
    has_many :vehicles, through: :registrations_vehicles
    has_one :donation_record, class_name: 'Donation'
    has_many :square_transactions, dependent: :destroy
    
    accepts_nested_attributes_for :user
    accepts_nested_attributes_for :attendees, allow_destroy: true
    accepts_nested_attributes_for :transactions, allow_destroy: true
    
    scope :current, -> { where(year: Date.current.year) }
    scope :alpha, -> { joins(:user).order( :last_name )}

    attribute :donation, :decimal, default: 0.0
    attribute :paid_amount, :decimal, default: 0.0
    attribute :total, :decimal, default: 0.0
    
    validate :validate_minimum_number_of_adults, unless: -> { status.nil? || status.match(/^cancelled/) }
    validate :validate_payment, unless: -> { status.nil? || status.match(/^cancelled/) }
    validates :paid_method, inclusion: { in: Rails.configuration.rendezvous[:payment_methods] }, allow_blank: true
    # validates :invoice_number, uniqueness: true, format: { with: /\ARR20\d{2}-\d{3,4}\z/, on: :new }, allow_blank: true
    
    validates :status, inclusion: { in: Rails.configuration.rendezvous[:registration_statuses] }
    
    serialize :events, JSON

    before_save :ensure_total
    
    def validate_minimum_number_of_adults
      if number_of_adults < 1
        errors[:base] << "You must register at least one adult."
      end
    end
    
    def validate_payment
      if !self.paid_amount.nil?
        if (self.paid_amount.to_f > self.total.to_f)
          errors[:base] << "The paid amount is more than the owed amount."
        end
      end
    end

    def number_of_people
      self.attendees.count
    end

    def number_of_volunteers
      self.attendees.where(volunteer: true).count
    end
      
    def balance
      self.total.to_f - self.paid_amount.to_f
    end
    
    def outstanding_balance?
      self.balance > 0.0
    end

    def owed_a_refund?
      balance < 0.0
    end

    def complete?
      self.status == 'complete'
    end

    def cancelled?
      self.status =~ /cancelled/
    end

    def ensure_total
      self.total = self.registration_fee || 0.0
      if !self.donation.blank?
        self.total += self.donation
      end
      if !self.vendor_fee.blank?
        self.total += self.vendor_fee
      end
    end
    
    def self.invoice_number
      prefix = "CR#{Rails.configuration.rendezvous[:dates][:year]}"
      previous_code = Registration.pluck(:invoice_number).last
      if previous_code.blank?
        next_number = 101
      else
        next_number = /-(\d+)\z/.match(previous_code)[1].to_i + 1
      end
      "#{prefix}-#{next_number}"
    end
  end
end


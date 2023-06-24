
module Event
  class Registration < ActiveRecord::Base
    
    belongs_to :user
    has_many :attendees, dependent: :destroy
    has_many :transactions, dependent: :destroy
    
    accepts_nested_attributes_for :user
    accepts_nested_attributes_for :attendees, allow_destroy: true
    accepts_nested_attributes_for :transactions, allow_destroy: true
    
    scope :current, -> { where(year: Time.now.year) }
    scope :alpha, -> { joins(:user).order( :last_name )}
    
    validate :validate_minimum_number_of_adults, unless: -> { status.match(/^cancelled/) }
    validate :validate_payment, unless: -> { status.match(/^cancelled/) }
    validates :paid_method, inclusion: { in: Rails.configuration.rendezvous[:payment_methods] }, allow_blank: true
    # validates :invoice_number, uniqueness: true, format: { with: /\ARR20\d{2}-\d{3,4}\z/, on: :new }, allow_blank: true
    
    validates :status, inclusion: { in: Rails.configuration.rendezvous[:registration_statuses] }
    
    serialize :events, JSON
    
    def validate_minimum_number_of_adults
      if number_of_adults + number_of_seniors < 1
        errors[:base] << "You must register at least one adult or senior."
      end
    end
    
    def validate_payment
      if !paid_amount.nil?
        if (paid_amount.to_f > total.to_f)
          errors[:base] << "The paid amount is more than the owed amount."
        end
      end
    end
      
    def balance
      total.to_f - paid_amount.to_f
    end
    
    def paid?
      !(balance > 0.0)
    end

    def complete?
      status == 'complete'
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


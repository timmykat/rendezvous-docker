# == Schema Information
#
# Table name: registrations
#
#  id                  :integer          not null, primary key
#  annual_answer       :string(255)
#  balance             :decimal(8, 2)    default(0.0), not null
#  created_by_admin    :boolean          default(FALSE), not null
#  donation            :decimal(8, 2)
#  events              :text(65535)
#  invoice_number      :string(255)
#  is_admin_created    :boolean          default(FALSE), not null
#  lake_cruise_fee     :decimal(8, 2)
#  lake_cruise_number  :integer          default(0), not null
#  number_of_adults    :integer
#  number_of_children  :integer
#  number_of_seniors   :integer
#  number_of_youths    :integer
#  paid_amount         :decimal(8, 2)
#  paid_date           :datetime
#  paid_method         :string(255)
#  refunded            :decimal(8, 2)    default(0.0), not null
#  registration_fee    :decimal(8, 2)
#  status              :string(255)
#  sunday_lunch_number :integer          default(0), not null
#  total               :decimal(8, 2)
#  vendor_fee          :decimal(6, 2)
#  year                :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#  cc_transaction_id   :string(255)
#  user_id             :integer
#
# Indexes
#
#  index_registrations_on_balance            (balance)
#  index_registrations_on_cc_transaction_id  (cc_transaction_id)
#  index_registrations_on_invoice_number     (invoice_number)
#  index_registrations_on_paid_amount        (paid_amount)
#  index_registrations_on_paid_date          (paid_date)
#  index_registrations_on_paid_method        (paid_method)
#  index_registrations_on_refunded           (refunded)
#  index_registrations_on_status             (status)
#  index_registrations_on_year               (year)
#
module Event
  class Registration < ApplicationRecord

    include AdminCreatable

    belongs_to :user
    has_many :attendees, dependent: :destroy
    has_many :transactions, class_name: 'SquareTransaction', dependent: :destroy
    has_many :registrations_vehicles, class_name: 'RegistrationsVehicles', foreign_key: :registration_id, dependent: :destroy
    has_many :vehicles, through: :registrations_vehicles
    has_one :donation_record, class_name: 'Donation'
    has_many :square_orders, class_name: "Square::Order", dependent: :destroy
    has_many :square_transactions, dependent: :destroy

    accepts_nested_attributes_for :user
    accepts_nested_attributes_for :attendees, allow_destroy: true
    accepts_nested_attributes_for :transactions, allow_destroy: true

    scope :current, -> { where(year: Date.current.year) }
    scope :alpha, -> { joins(:user).order(:last_name) }

    attribute :donation, :decimal, default: 0.0
    attribute :paid_amount, :decimal, default: 0.0
    attribute :total, :decimal, default: 0.0

    STATUSES = [
      'new',
      'in progress',
      'in review',
      'payment due',
      'complete',
      'cancelled - settled',
      'cancelled - needs refund'
    ]

    validate :validate_minimum_number_of_adults, unless: -> { status.nil? || status.match(/^cancelled/) }
    validate :validate_payment, unless: -> { status.nil? || status.match(/^cancelled/) }
    validates :paid_method, inclusion: { in: Rails.configuration.registration[:payment_methods] }, allow_blank: true
    # validates :invoice_number, uniqueness: true, format: { with: /\ARR20\d{2}-\d{3,4}\z/, on: :new }, allow_blank: true

    validates :status, inclusion: { in: STATUSES }

    validates :sunday_lunch_number,
              numericality: {
                only_integer: true,
                greater_than_or_equal_to: 0,
                less_than_or_equal_to: Rails.configuration.registration[:sunday_lunch_max]
              }
    validates :lake_cruise_number,
              numericality: {
                only_integer: true,
                greater_than_or_equal_to: 0,
                less_than_or_equal_to: Rails.configuration.registration[:lake_cruise_max]
              }

    serialize :events

    before_save :ensure_financials

    def total_paid_cents
      # Quick way to get the sum of all completed payments across all orders
      square_orders.joins(:payments).where(square_payments: { status: 'COMPLETED' }).sum(:amount_cents)
    end

    def validate_minimum_number_of_adults
      if number_of_adults < 1
        errors[:base] << "You must register at least one adult."
      end
    end

    def validate_payment
      if !paid_amount.nil?
        if (paid_amount.to_d > total.to_d)
          errors[:base] << "The paid amount is more than the owed amount."
        end
      end
    end

    def number_of_people
      attendees.count
    end

    def number_of_volunteers
      attendees.where(volunteer: true).count
    end

    def outstanding_balance?
      balance > 0.0
    end

    def owed_a_refund?
      balance < 0.0
    end

    def complete?
      status == 'complete'
    end

    def cancelled?
      status =~ /cancelled/
    end

    def ensure_financials
      self.total = registration_fee.to_d +
                   donation.to_d +
                   lake_cruise_fee.to_d

      self.balance = self.total - (paid_amount.to_d + refunded.to_d)
    end

    def self.invoice_number
      prefix = "CR#{Rails.configuration.site[:dates][:year]}"
      previous_code = Registration.pluck(:invoice_number).last
      if previous_code.blank?
        next_number = 101
      else
        next_number = /-(\d+)\z/.match(previous_code)[1].to_i + 1
      end
      "#{prefix}-#{next_number}"
    end

    def total_of_payments
      (payments.where(status: 'COMPLETE').sum(:amount_cents) / 100.0).to_d
    end

    def total_of_refunded
      # Sums all completed refunds tied to this registration's payments
      refunds.where(status: 'COMPLETED').sum(:amount_cents) / 100.0
    end

    def was_paid(amount)
      if paid_amount == amount
        self.status = 'complete - confirmed'
        self.save
      end
    end
  end
end

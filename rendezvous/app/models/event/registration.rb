# == Schema Information
#
# Table name: registrations
#
#  id                  :integer          not null, primary key
#  annual_answer       :string(255)
#  balance             :decimal(8, 2)    default(0.0), not null
#  created_by_admin    :boolean          default(FALSE), not null
#  donation            :decimal(8, 2)    default(0.0)
#  events              :text(65535)
#  invoice_number      :string(255)
#  is_admin_created    :boolean          default(FALSE), not null
#  lake_cruise_fee     :decimal(8, 2)    default(0.0)
#  lake_cruise_number  :integer          default(0), not null
#  late_period         :boolean          default(FALSE)
#  number_of_adults    :integer          default(0)
#  number_of_children  :integer          default(0)
#  number_of_seniors   :integer          default(0)
#  number_of_youths    :integer          default(0)
#  paid_amount         :decimal(8, 2)    default(0.0)
#  paid_date           :datetime
#  paid_method         :string(255)
#  refunded            :decimal(8, 2)    default(0.0), not null
#  registration_fee    :decimal(8, 2)    default(0.0)
#  status              :string(255)      default("pending")
#  step                :string(255)      default("creating")
#  sunday_lunch_number :integer          default(0), not null
#  total               :decimal(8, 2)    default(0.0)
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
    has_many :transactions, class_name: '::Square::Transaction', dependent: :destroy
    has_many :registrations_vehicles, class_name: 'RegistrationsVehicles', foreign_key: :registration_id, dependent: :destroy
    has_many :vehicles, through: :registrations_vehicles
    has_one :donation_record, class_name: 'Donation'
    has_many :square_transactions, class_name: '::Square::Transaction', dependent: :destroy
    has_many :modifications, inverse_of: :registration, dependent: :destroy

    accepts_nested_attributes_for :user
    accepts_nested_attributes_for :attendees, allow_destroy: true
    accepts_nested_attributes_for :transactions, allow_destroy: true
    accepts_nested_attributes_for :modifications, allow_destroy: true

    scope :current, -> { where(year: Date.current.year) }
    scope :alpha, -> { joins(:user).order(:last_name) }

    attribute :donation, :decimal, default: 0.0
    attribute :paid_amount, :decimal, default: 0.0
    attribute :total, :decimal, default: 0.0

    # Constants
    enum status: {
      n_a: 'N/A',
      pending: 'pending',
      in_progress: 'in progress',
      complete: 'complete',
      cancelled: 'cancelled'
    }

    enum step: {
      creating: 'creating',
      special_events: 'special events',
      review: 'review',
      payment: 'payment',
      finished: 'finished'
    }

    enum paid_method: {
      credit_card: 'credit card',
      cash_or_check: 'cash or check',
      invoice: 'invoice'
    }

    enum fee_period: {
      early: 'early',
      late: 'late',
      on_site: 'on site',
      day_of: 'day off'
    }

    AGE_GROUPS = %w[adult youth child].freeze

    PAYMENT_STATUSES = {
      paid: 'paid',
      outstanding_balance: 'outstanding balance',
      payment_due: 'payment due',
      refund_owed: 'refund owed',
      refunded: 'refunded'
    }.freeze

    # Validations
    validate :validate_minimum_number_of_adults, unless: -> { cancelled? }
    validate :validate_payment, unless: -> { status.nil? || cancelled? }

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

    def self.status_options
      statuses.keys.map { |k| [k.humanize, k] }
    end

    def self.paid_method_options
      paid_methods.keys.map { |k| [k.humanize, k] }
    end

    def cancelled?
      status == :cancelled
    end

    # Payment checks
    def refunded?
      cancelled? and balance.to_d.zero?
    end

    def paid?
      total.to_d == paid_amount.to_d
    end

    def payment_due?
      paid_amount.to_d.zero?
    end

    def show_payment_button?
      !(outstanding_balance? || paid?)
    end

    def outstanding_balance?
      (total.to_d > paid_amount.to_d) && paid_amount.positive?
    end

    def refund_due?
      balance.to_d.negative?
    end

    def payment_status
      return 'refunded' if refunded?
      return 'paid' if paid?
      return 'outstanding balance' if outstanding_balance?

      'payment due'
    end

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

    def ensure_financials
      self.total = registration_fee.to_d +
                   donation.to_d +
                   lake_cruise_fee.to_d

      self.balance = self.total - (paid_amount.to_d + refunded.to_d)
    end

    def modification_amount
      modifications&.sum(&:modification_total) || 0.0
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

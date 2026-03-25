module Square
  class Order < ApplicationRecord
    belongs_to :registration
    has_many :square_payments, dependent: :destroy

    validates :square_order_id, presence: true, uniqueness: true
    validates :total_amount_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :status, presence: true # OPEN, COMPLETED, CANCELED

    def total_captured_cents
      payments.where(status: "COMPLETED").sum(:amount_cents) - 
      payments.joins(:refunds).where(square_refunds: { status: "COMPLETED" }).sum('square_refunds.amount_cents')
    end
  end
end

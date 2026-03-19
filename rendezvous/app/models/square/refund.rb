module Square
  class Refund < ApplicationRecord
    belongs_to :payment, class_name: "Square::Payment"
    has_one :registration, through: :payment

    # Validations
    validates :square_refund_id, presence: true, uniqueness: true
    validates :amount_cents, presence: true, numericality: { greater_than: 0 }
    validates :status, presence: true # e.g., PENDING, COMPLETED, FAILED

  end
end

module Square
  class Payment < ApplicationRecord
    belongs_to :registration, class_name: 'Event::Registration', optional: true
    has_many :square_refunds, dependent: :destroy

    validates :square_payment_id, presence: true, uniqueness: true
    validates :amount_cents, presence: true, numericality: { greater_than: 0 }
    validates :status, presence: true # COMPLETED, FAILED, VOIDED
  end
end

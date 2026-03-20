# == Schema Information
#
# Table name: transactions
#
#  id                 :integer          not null, primary key
#  amount_cents       :integer
#  transaction_type   :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  cc_transaction_id  :string(255)
#  registration_id    :integer
#
# Indexes
#
#  index_transactions_on_cc_transaction_id   (cc_transaction_id)
#  index_transactions_on_transaction_method  (transaction_method)
#  index_transactions_on_transaction_type    (transaction_type)
#
module Square
  class Transaction < ApplicationRecord
    self.table_name = "square_transactions"
    
    belongs_to :registration, class_name: 'Event::Registration', optional: true
    belongs_to :user, optional: true

    validates :transaction_type, presence: true, inclusion: { in: %w[order payment refund] }
    validates :amount_cents, presence: true

    validates :amount_cents, 
              numericality: { less_than: 0 }, 
              if: :refund?

    validates :amount_cents, 
              numericality: { greater_than_or_equal_to: 0 }, 
              unless: :refund?

    def refund?
      transaction_type == 'refund'
    end
  end
end

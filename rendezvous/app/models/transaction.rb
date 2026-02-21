# == Schema Information
#
# Table name: transactions
#
#  id                 :integer          not null, primary key
#  amount             :decimal(6, 2)    default(0.0)
#  transaction_method :string(255)
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
class Transaction < ApplicationRecord

  belongs_to :registration, class_name: 'Event::Registration'

  attribute :amount, :decimal, default: 0.0
  
  validates :transaction_type, inclusion: { in: ['payment', 'refund', 'none'] }
  validates :transaction_method, inclusion: { in: Rails.configuration.registration[:payment_methods] }

  validate :validate_amount_and_type
  
  def validate_amount_and_type
    if amount < 0.0
      errors[:base] << "An amount less than zero must be a refund" unless /refund/.match(transaction_type)
    elsif amount > 0.0
      errors[:base] << "An amount greater than zero must be a payment" unless /payment/.match(transaction_type)
    elsif transaction_type != 'none'
      errors[:base] << "Only no transaction can have a zero amount"
    end
  end
  
end

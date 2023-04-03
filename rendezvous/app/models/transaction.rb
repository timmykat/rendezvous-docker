class Transaction < ActiveRecord::Base

  belongs_to :registration
  
  validates :transaction_type, inclusion: { in: ['payment', 'refund'] }
  validates :transaction_method, inclusion: { in: Rails.configuration.rendezvous[:payment_methods] }

  validate :validate_amount_and_type
  
  def validate_amount_and_type
    if amount < 0.0
      errors.add_to_base "An amount less than zero must be a refund" unless /refund/.match(transaction_type)
    elsif amount > 0.0
      errors.add_to_base "An amount greater than zero must be a payment" unless /payment/.match(transaction_type)
    else
      errors.add_to_base "A transaction cannot have a zero amount"
    end
  end
  
end
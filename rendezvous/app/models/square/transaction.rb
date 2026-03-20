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
module Square
  class Transaction < ApplicationRecord
    belongs_to :registration, class_name: 'Event::Registration', optional: true
    belongs_to :donation, optional: true
    belongs_to :user
  end
end

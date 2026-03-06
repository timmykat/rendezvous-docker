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
require 'rails_helper'

RSpec.describe Transaction, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

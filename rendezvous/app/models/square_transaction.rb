# == Schema Information
#
# Table name: square_transactions
#
#  id              :bigint           not null, primary key
#  amount          :decimal(6, 2)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  donation_id     :bigint
#  order_id        :string(255)
#  registration_id :integer
#  transaction_id  :string(255)
#  user_id         :integer          not null
#
# Indexes
#
#  index_square_transactions_on_donation_id      (donation_id)
#  index_square_transactions_on_registration_id  (registration_id)
#  index_square_transactions_on_user_id          (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (donation_id => donations.id)
#  fk_rails_...  (registration_id => registrations.id)
#  fk_rails_...  (user_id => users.id)
#
class SquareTransaction < ApplicationRecord
  belongs_to :registration, optional: true
  belongs_to :donation, optional: true
  belongs_to :user
end

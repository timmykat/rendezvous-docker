# == Schema Information
#
# Table name: square_transactions
#
#  id                :bigint           not null, primary key
#  amount_cents      :integer          default(0)
#  currency          :string(255)      default("USD")
#  email             :string(255)
#  square_created_at :datetime
#  status            :string(255)
#  transaction_type  :string(255)      not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  registration_id   :integer
#  square_id         :string(255)      not null
#  user_id           :integer
#
# Indexes
#
#  index_square_transactions_on_email            (email)
#  index_square_transactions_on_registration_id  (registration_id)
#  index_square_transactions_on_square_id        (square_id) UNIQUE
#  index_square_transactions_on_user_id          (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (registration_id => registrations.id)
#  fk_rails_...  (user_id => users.id)
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

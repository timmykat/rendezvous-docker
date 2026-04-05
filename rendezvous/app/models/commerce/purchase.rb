# == Schema Information
#
# Table name: purchases
#
#  id                    :bigint           not null, primary key
#  cash_amount           :decimal(6, 2)
#  cash_check_paid       :decimal(6, 2)    default(0.0)
#  category              :string(255)
#  country               :string(255)
#  email                 :string(255)
#  first_name            :string(255)
#  generic_amount        :decimal(6, 2)
#  last_name             :string(255)
#  paid_method           :string(255)
#  postal_code           :string(255)
#  total                 :decimal(6, 2)
#  transaction_amount    :decimal(6, 2)
#  untracked_merchandise :text(65535)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  cc_transaction_id     :string(255)
#
# Indexes
#
#  index_purchases_on_email  (email)
#
module Commerce
    class Purchase < ApplicationRecord

        attribute :amount, :decimal, default: 0.0
        attribute :cc_transaction_amount, :decimal, default: 0.0
        attribute :cash_check_paid, :decimal, default: 0.0

        has_many :cart_items, class_name: 'Commerce::CartItem'

        accepts_nested_attributes_for :cart_items, allow_destroy: true

        validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }, presence: true

        validates :postal_code, presence: true

        validates :category, inclusion: { in: ['merch', 'silent auction', 'donation'] }
        validates :country, inclusion: { in: ['USA', 'CAN'] }

        def balance
            return total - cc_transaction_amount - cash_check_paid
        end

        def name_for_alpha
            return "#{last_name}, #{first_name}"
        end

        def full_name
            return "#{first_name} #{last_name}"
        end
    end
end

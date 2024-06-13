module Commerce
    class Purchase < ActiveRecord::Base

        attribute :amount, :decimal, default: 0.0
        attribute :cc_transaction_amount, :decimal, default: 0.0
        attribute :cash_amount, :decimal, default: 0.0

        has_many :cart_items

        accepts_nested_attributes_for :cart_items, allow_destroy: true

        validates :first_name, presence: true
        validates :last_name, presence: true
        validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }, presence: true
        validates :postal_code, presence: true

        validates :amount, comparison: { greater_than: 10.0 }
        validates :category, inclusion: { in: ['registration', 'merch', 'donation', 'multiple'] }
        validates :country, inclusion: { in: ['USA', 'CAN'] }

        def balance
            return amount - cc_transaction_amount - cash_amount
        end

        def name_for_alpha
            return "#{last_name}, #{first_name}"
        end

        def full_name
            return "#{first_name} #{last_name}"
        end
    end
end

module Commerce
    class Purchase < ActiveRecord::Base

        attribute :amount, :decimal, default: 0.0
        attribute :cc_transaction_amount, :decimal, default: 0.0
        attribute :cash_check_paid, :decimal, default: 0.0

        has_many :cart_items, class_name: 'Commerce::CartItem'

        accepts_nested_attributes_for :cart_items, allow_destroy: true

        validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }, 
            presence: true, if: Proc.new { |p| p.paid_method == 'credit card' }

        validates :postal_code, 
            presence: true, if: Proc.new { |p| p.paid_method == 'credit card' }

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

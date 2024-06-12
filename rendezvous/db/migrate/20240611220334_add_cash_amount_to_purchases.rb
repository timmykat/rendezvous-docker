class AddCashAmountToPurchases < ActiveRecord::Migration[7.1]
  def change
    add_column :purchases, :cash_check_paid, :decimal, precision: 6, scale: 2, default: 0.0
  end
end

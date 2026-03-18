class AddBalanceColumnToRegistrations < ActiveRecord::Migration[7.2]
  def change
    add_column :registrations, :balance, :decimal, precision: 8, scale: 2, default: 0.0
    add_index :registrations, :balance

    up_only do
      Event::Registration.update_all("balance = COALESCE(total, 0) - COALESCE(paid_amount, 0)")
      change_column_null :registrations, :balance, false
    end
  end
end

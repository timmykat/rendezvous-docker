class AddRefundedToRegistration < ActiveRecord::Migration[7.2]
  def change
    add_column :registrations, :refunded, :decimal, precision: 8, scale: 2, default: 0.0, null: false
    add_index :registrations, :refunded
  end
end

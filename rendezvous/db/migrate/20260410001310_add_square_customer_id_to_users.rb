class AddSquareCustomerIdToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :square_customer_id, :string, null: true
    add_index :users, :square_customer_id
  end
end

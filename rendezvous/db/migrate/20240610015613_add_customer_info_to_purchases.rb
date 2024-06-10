class AddCustomerInfoToPurchases < ActiveRecord::Migration[7.1]
  def change
    add_column :purchases, :email, :string
    add_column :purchases, :first_name, :string
    add_column :purchases, :last_name, :string
    add_column :purchases, :postal_code, :string
    add_column :purchases, :country, :string

    add_index :purchases, :email, name: "index_purchases_on_email"
  end
end

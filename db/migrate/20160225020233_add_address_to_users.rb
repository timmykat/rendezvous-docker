class AddAddressToUsers < ActiveRecord::Migration
  def change
    add_column :users, :address1, :string
    add_column :users, :address2, :string
    add_column :users, :city, :string
    add_column :users, :state_or_province, :string
    add_column :users, :postal_code, :string
    add_column :users, :country, :string
    
    add_index :users, :state_or_province
    add_index :users, :country
  end
end

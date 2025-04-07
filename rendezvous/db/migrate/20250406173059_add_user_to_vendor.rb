class AddUserToVendor < ActiveRecord::Migration[7.1]
  def change
    add_column :vendors, :user_id, :integer
    add_foreign_key :vendors, :users
  end
end

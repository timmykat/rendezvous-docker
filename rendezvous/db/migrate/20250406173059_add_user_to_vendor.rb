class AddUserToVendor < ActiveRecord::Migration[7.1]
  def change
    remove_foreign_key :vendors, :users rescue nil

    change_column :vendors, :user_id, :integer

    add_foreign_key :vendors, :users
  end
end

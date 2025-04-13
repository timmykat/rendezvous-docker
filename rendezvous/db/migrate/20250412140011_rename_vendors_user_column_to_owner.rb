class RenameVendorsUserColumnToOwner < ActiveRecord::Migration[7.1]
  def change
    rename_column :vendors, :user_id, :owner_id

    remove_foreign_key :vendors, :users rescue nil

    add_foreign_key :vendors, :users, column: :owner_id
  end
end
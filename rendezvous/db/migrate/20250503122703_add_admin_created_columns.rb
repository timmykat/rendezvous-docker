class AddAdminCreatedColumns < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :is_admin_created, :boolean, default: false
    add_column :registrations, :is_admin_created, :boolean, default: false, null: false
  end
end

class AddCreatedByAdminToDonations < ActiveRecord::Migration[7.1]
  def change
    add_column :donations, :created_by_admin, :boolean, default: false, null: false
  end
end

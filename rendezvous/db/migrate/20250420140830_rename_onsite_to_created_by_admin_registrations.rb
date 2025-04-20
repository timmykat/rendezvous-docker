class RenameOnsiteToCreatedByAdminRegistrations < ActiveRecord::Migration[7.1]
  def change
    rename_column :registrations, :onsite, :created_by_admin
    change_column_default :registrations, :created_by_admin, from: nil, to: false
    change_column_null :registrations, :created_by_admin, false
  end
end

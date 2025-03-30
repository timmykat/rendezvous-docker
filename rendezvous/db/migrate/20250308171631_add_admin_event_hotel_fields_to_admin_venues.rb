class AddAdminEventHotelFieldsToAdminVenues < ActiveRecord::Migration[7.1]
  def change
    add_column :admin_venues, :reservation_url, :string
    add_column :admin_venues, :group_code, :string
    add_column :admin_venues, :rooms_available, :integer
    add_column :admin_venues, :close_date, :date
    add_column :admin_venues, :type, :string # For STI
  end
end

class AddVenueWebsite < ActiveRecord::Migration[7.1]
  def change
    add_column :admin_venues, :website, :string
  end
end

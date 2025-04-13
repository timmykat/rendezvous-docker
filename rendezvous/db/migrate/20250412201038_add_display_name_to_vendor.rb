class AddDisplayNameToVendor < ActiveRecord::Migration[7.1]
  def change
    add_column :vendors, :owner_display_name, :string
  end
end

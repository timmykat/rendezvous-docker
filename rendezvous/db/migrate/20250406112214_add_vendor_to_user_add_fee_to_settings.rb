class AddVendorToUserAddFeeToSettings < ActiveRecord::Migration[7.1]
  
  # Vendor users handle via roles
  def change
    add_column :site_settings, :vendor_fee, :decimal, precision: 6, scale: 2
    add_column :registrations, :vendor_fee,  :decimal, precision: 6, scale: 2
  end
end

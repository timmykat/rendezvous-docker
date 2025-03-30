class AddOrderFieldToVendor < ActiveRecord::Migration[7.1]
  def change
    add_column :vendors, :order, :integer
    add_index :vendors, :order
  end
end

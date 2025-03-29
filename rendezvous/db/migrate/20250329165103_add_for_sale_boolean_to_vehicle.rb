class AddForSaleBooleanToVehicle < ActiveRecord::Migration[7.1]
  def change
    add_column :vehicles, :for_sale, :boolean
    add_index :vehicles, :for_sale
  end
end

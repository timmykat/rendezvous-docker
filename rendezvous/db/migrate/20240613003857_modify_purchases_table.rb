class ModifyPurchasesTable < ActiveRecord::Migration[7.1]
  def change
    add_column :purchases, :total, :decimal, precision: 6, scale: 2
    rename_column :merchitems, :inventory, :starting_inventory
  end
end

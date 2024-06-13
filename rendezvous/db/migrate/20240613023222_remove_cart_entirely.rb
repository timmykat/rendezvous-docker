class RemoveCartEntirely < ActiveRecord::Migration[7.1]
  def change
    drop_table :carts
    rename_column :cart_items, :cart_id, :purchase_id
  end
end

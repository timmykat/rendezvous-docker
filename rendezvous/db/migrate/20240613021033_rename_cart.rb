class RenameCart < ActiveRecord::Migration[7.1]
  def change
    rename_table :cart, :carts
  end
end

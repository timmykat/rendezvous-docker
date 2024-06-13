class CreateCartTableWithCartItems < ActiveRecord::Migration[7.1]
  def change
    create_table :cart_items do |t|
      t.references :merchitem
      t.references :cart
      t.integer :number, default: 1

      t.timestamps
    end    
    create_table :cart do |t|
      t.references :purchase
      t.references :cart_items
      t.timestamps
    end
  end
end

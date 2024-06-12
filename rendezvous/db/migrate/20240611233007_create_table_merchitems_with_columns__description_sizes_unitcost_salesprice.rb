class CreateTableMerchitemsWithColumnsDescriptionSizesUnitcostSalesprice < ActiveRecord::Migration[7.1]
  def change
    create_table :merchitems do |t|
      t.string :sku
      t.string :size
      t.integer :inventory

      t.index ["sku"], name: "index_merchitems_on_sku"

      t.timestamps
    end

    create_table :merchandise do |t|
      t.string :sku
      t.string :description
      t.decimal :unit_cost, precision: 6, scale: 2
      t.decimal :sale_price, precision: 6, scale: 2
      t.references :merchitems

      t.index ["sku"], name: "index_merchandise_on_sku"

      t.timestamps
    end
  end
end

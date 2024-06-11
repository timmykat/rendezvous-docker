class CreatePurchases < ActiveRecord::Migration[7.1]
  def change
    create_table :purchases do |t|
      t.text :description
      t.decimal :amount, precision: 6, scale: 2
      t.string :category

      t.timestamps
    end
  end
end

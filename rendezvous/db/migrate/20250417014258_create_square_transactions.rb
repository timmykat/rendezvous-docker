class CreateSquareTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :square_transactions do |t|
      t.string :order_id
      t.string :transaction_id
      t.decimal :amount, precision: 6, scale: 2
      t.references :user, null: false, foreign_key: true, type: :int
      t.references :registration, null: true, foreign_key: true, type: :int
      t.references :donation, null: true, foreign_key: true

      t.timestamps
    end
  end
end

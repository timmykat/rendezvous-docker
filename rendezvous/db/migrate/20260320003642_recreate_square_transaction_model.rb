class RecreateSquareTransactionModel < ActiveRecord::Migration[7.2]
  def change
    drop_table :square_transactions, if_exists: true

    create_table :square_transactions do |t|
      t.references :registration, null: true, foreign_key: true
      t.references :user, null: true, foreign_key: true
      
      # The "Type" tells us if it's an order, payment, or refund
      t.string :transaction_type, null: false
      t.string :square_id, null: false
      t.integer :amount_cents, default: 0
      t.string :currency, default: 'USD'
      t.string :status
      t.string :email
      t.datetime :square_created_at # The "Basic" time you wanted
      
      t.timestamps
    end

    add_index :square_transactions, :email
    add_index :square_transactions, :square_id, unique: true
  end
end

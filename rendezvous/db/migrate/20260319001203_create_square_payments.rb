class CreateSquarePayments < ActiveRecord::Migration[7.2]
  def change
    create_table :square_payments, id: false do |t|
      t.references :registration, null: false, foreign_key: true
      t.string :square_payment_id, primary_key: true
      t.integer :amount_cents
      t.string :currency

      t.timestamps
    end
  end
end

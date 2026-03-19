class CreateSquareRefunds < ActiveRecord::Migration[7.2]
  def change
    create_table :square_refunds, id: false do |t|
      t.references :payment, null: false, foreign_key: true
      t.string :square_refund_id, primary_key: true
      t.integer :amount_cents
      t.string :reason
      t.string :status

      t.timestamps
    end
  end
end

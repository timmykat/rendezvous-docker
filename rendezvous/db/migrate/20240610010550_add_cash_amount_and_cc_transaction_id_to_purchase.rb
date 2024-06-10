class AddCashAmountAndCcTransactionIdToPurchase < ActiveRecord::Migration[7.1]
  def change
    add_column :purchases, :cc_transaction_id, :string
    add_column :purchases, :transaction_amount, :decimal, precision: 6, scale: 2
    add_column :purchases, :cash_amount, :decimal, precision: 6, scale: 2
  end
end

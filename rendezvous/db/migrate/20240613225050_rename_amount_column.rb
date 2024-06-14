class RenameAmountColumn < ActiveRecord::Migration[7.1]
  def change
    rename_column :purchases, :amount, :generic_amount
  end
end

class AddPaidMethodToPurchases < ActiveRecord::Migration[7.1]
  def change
    add_column :purchases, :paid_method, :string
  end
end

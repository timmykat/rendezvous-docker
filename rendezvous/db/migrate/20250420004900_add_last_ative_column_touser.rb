class AddLastAtiveColumnTouser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :last_active, :datetime
    add_index :users, :last_active
  end
 
end

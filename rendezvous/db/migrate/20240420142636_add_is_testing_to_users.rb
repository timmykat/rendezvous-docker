class AddIsTestingToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :is_testing, :boolean, default: false
  end
end

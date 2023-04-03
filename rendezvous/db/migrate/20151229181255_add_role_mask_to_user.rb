class AddRoleMaskToUser < ActiveRecord::Migration
  def change
    add_column :users, :role_mask, :integer
  end
end

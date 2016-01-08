class AddMailingToUser < ActiveRecord::Migration
  def change
    add_column :users, :receive_mailings, :boolean, default: true
    add_index :users, :receive_mailings
  end
end

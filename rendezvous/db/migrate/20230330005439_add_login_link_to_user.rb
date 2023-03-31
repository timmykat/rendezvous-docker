class AddLoginLinkToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :login_token, :string
    add_column :users, :login_token_sent_at , :datetime

    add_index  :users, :login_token, :unique => true  end
end

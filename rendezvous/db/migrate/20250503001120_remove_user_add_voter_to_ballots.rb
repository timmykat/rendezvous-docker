class RemoveUserAddVoterToBallots < ActiveRecord::Migration[7.1]
  def change
    remove_foreign_key :ballots, :users
    remove_column :ballots, :user_id

    add_column :ballots, :voter_id, :string, limit: 36
    add_index :ballots, :voter_id
  end
end

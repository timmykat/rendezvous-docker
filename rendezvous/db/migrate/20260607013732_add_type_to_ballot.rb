class AddTypeToBallot < ActiveRecord::Migration[7.2]
  def change
    add_column :ballots, :ballot_type, :string, null: false
    add_index :ballots, :ballot_type
  end
end

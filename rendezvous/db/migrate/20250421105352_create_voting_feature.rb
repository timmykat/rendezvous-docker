class CreateVotingFeature < ActiveRecord::Migration[7.1]

  def up
    create_table :ballots do |t|
      t.string :year
      t.string :status
      t.references :user, foreign_key: true, type: :int    
      t.timestamps
    end

    add_index :ballots, :year

    create_table :ballot_selections do |t|
      t.references :ballot, foreign_key: true
      t.references :votable, polymorphic: true, null: false

      t.timestamps
    end
  end

  def down
    drop_table :ballot_selections
    drop_table :ballots
  end
end
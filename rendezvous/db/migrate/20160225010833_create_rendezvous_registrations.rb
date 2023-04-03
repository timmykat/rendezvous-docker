class CreateRendezvousRegistrations < ActiveRecord::Migration
  def change
    create_table :rendezvous_registrations do |t|
      t.integer :number_of_adults
      t.integer :number_of_children
      t.decimal :amount, precision: 6, scale: 2
      t.text    :events  # Serialized
      t.references :user
      
      t.timestamps
    end
  end
end

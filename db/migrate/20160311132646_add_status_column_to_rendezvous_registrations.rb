class AddStatusColumnToRendezvousRegistrations < ActiveRecord::Migration
  def change
    add_column :rendezvous_registrations, :status, :string
    add_index :rendezvous_registrations, :status
  end
end

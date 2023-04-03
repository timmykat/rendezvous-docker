class AddTotalToRendezvousRegistration < ActiveRecord::Migration
  def change
    add_column :rendezvous_registrations, :total, :float
  end
end

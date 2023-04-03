class AddYearToRendezvousRegistration < ActiveRecord::Migration
  def change
    add_column :rendezvous_registrations, :year, :string
    add_index :rendezvous_registrations, :year
  end
end

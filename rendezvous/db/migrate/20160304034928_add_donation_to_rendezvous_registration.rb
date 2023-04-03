class AddDonationToRendezvousRegistration < ActiveRecord::Migration
  def change
    add_column :rendezvous_registrations, :donation, :decimal, precision: 6, scale: 2
  end
end

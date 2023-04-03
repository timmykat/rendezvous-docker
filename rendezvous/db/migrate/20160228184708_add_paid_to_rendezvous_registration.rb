class AddPaidToRendezvousRegistration < ActiveRecord::Migration
  def change
    add_column :rendezvous_registrations, :paid_amount, :decimal, precision: 6, scale: 2
    add_column :rendezvous_registrations, :paid_method, :string
    add_column :rendezvous_registrations, :paid_date, :timestamp
    add_index :rendezvous_registrations, :paid_amount
    add_index :rendezvous_registrations, :paid_method
    add_index :rendezvous_registrations, :paid_date
  end
end

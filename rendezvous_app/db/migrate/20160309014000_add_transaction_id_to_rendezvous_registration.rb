class AddTransactionIdToRendezvousRegistration < ActiveRecord::Migration
  def change
    add_column :rendezvous_registrations, :cc_transaction_id, :string
    add_index :rendezvous_registrations, :cc_transaction_id
  end
end

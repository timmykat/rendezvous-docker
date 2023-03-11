class AddInvoiceNumberToRendezvousRegistration < ActiveRecord::Migration
  def change
    add_column :rendezvous_registrations, :invoice_number, :string
    add_index :rendezvous_registrations, :invoice_number
  end
end

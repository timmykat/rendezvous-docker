class RenameAmountToRegistrationFee < ActiveRecord::Migration
  def change
    rename_column :rendezvous_registrations, :amount, :registration_fee
  end
end

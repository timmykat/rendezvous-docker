class UpdateRegistrationsReferences < ActiveRecord::Migration[5.2]
  def change
    rename_column(:attendees, :rendezvous_registration_id, :registration_id)
    rename_column(:transactions, :rendezvous_registration_id, :registration_id)
  end
end

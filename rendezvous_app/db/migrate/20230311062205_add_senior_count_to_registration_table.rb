class AddSeniorCountToRegistrationTable < ActiveRecord::Migration[5.2]
  def change
    rename_table('rendezvous_registrations', 'registrations')
    add_column(:registrations, :number_of_seniors, :integer)
  end
end

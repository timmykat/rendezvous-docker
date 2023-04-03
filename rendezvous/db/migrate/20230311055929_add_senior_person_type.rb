class AddSeniorPersonType < ActiveRecord::Migration[5.2]
  def change
    rename_column(:attendees, :adult_or_child, :attendee_age) 
  end
end

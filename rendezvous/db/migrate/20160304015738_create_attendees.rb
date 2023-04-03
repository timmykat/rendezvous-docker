class CreateAttendees < ActiveRecord::Migration
  def change
    create_table :attendees do |t|
      t.string :name
      t.string :adult_or_child
      t.boolean :volunteer
      t.boolean :sunday_dinner
      t.references :rendezvous_registration

      t.timestamps null: false
    end
    add_index :attendees, :adult_or_child
    add_index :attendees, :volunteer
    add_index :attendees, :sunday_dinner
  end
end

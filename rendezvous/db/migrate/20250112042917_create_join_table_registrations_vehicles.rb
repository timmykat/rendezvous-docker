class CreateJoinTableRegistrationsVehicles < ActiveRecord::Migration[7.1]
  def change
    create_table :registrations_vehicles do |t|
      t.references :registration, null: false, foreign_key: true, type: :int
      t.references :vehicle, null: false, foreign_key: true, type: :int
    
      t.timestamps
    end
  end
end

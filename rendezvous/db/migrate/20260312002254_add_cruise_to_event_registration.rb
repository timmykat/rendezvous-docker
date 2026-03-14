class AddCruiseToEventRegistration < ActiveRecord::Migration[7.2]
  def change
    change_table :registrations, bulk: true do |t|
      t.integer :lake_cruise_number, default: 0, null: false
      t.decimal :lake_cruise_fee, precision: 6, scale: 2
      
      # Corrected the column name typo here
      t.check_constraint "lake_cruise_number >= 0 AND lake_cruise_number <= 8", name: "lake_cruise_limit"
    end
  end
end
class AddSundayLunchToRegistration < ActiveRecord::Migration[7.1]
  def change
    add_column :registrations, :sunday_lunch, :boolean, default: false, null: false
    add_column :registrations, :sunday_lunch_number, :integer, default: 0, null: false

    add_check_constraint :registrations,
      "(sunday_lunch = false AND sunday_lunch_number = 0) OR
       (sunday_lunch = true AND sunday_lunch_number >= 1)",
      name: "sunday_lunch_consistency"
      
  end
end

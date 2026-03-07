class RemoveSundayLunchFromRegistrations < ActiveRecord::Migration[7.2]
  def change
    # 1. Remove the consistency constraint
    remove_check_constraint :registrations, name: "sunday_lunch_consistency"

    remove_column :registrations, :sunday_lunch, :boolean, default: false, null: false

    # New constraint: Ensure number is between 0 and 8
    add_check_constraint :registrations, "sunday_lunch_number >= 0 AND sunday_lunch_number <= 8", name: "sunday_lunch_limit"
  end
end

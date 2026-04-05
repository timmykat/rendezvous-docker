class AddLatePeriodToRegistrations < ActiveRecord::Migration[7.2]
  def change
    add_column :registrations, :late_period, :boolean, default: false
  end
end

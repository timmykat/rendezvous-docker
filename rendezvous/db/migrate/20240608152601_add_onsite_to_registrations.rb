class AddOnsiteToRegistrations < ActiveRecord::Migration[7.1]
  def change
    add_column :registrations, :onsite, :boolean, default: false
  end
end

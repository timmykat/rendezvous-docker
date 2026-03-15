class AddCostEventToScheduledEvent < ActiveRecord::Migration[7.2]
  def change
    add_column :scheduled_events, :extra_cost, :boolean, default: false
  end
end

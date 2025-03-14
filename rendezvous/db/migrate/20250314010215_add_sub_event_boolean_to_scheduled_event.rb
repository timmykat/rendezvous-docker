class AddSubEventBooleanToScheduledEvent < ActiveRecord::Migration[7.1]
  def change
    add_column :admin_scheduled_events, :subevent, :boolean
    add_index :admin_scheduled_events, :subevent
  end
end

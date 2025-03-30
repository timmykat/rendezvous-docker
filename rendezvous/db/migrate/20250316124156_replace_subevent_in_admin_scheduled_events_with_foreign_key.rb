class ReplaceSubeventInAdminScheduledEventsWithForeignKey < ActiveRecord::Migration[7.1]
  def change
    # Set up parent
    # add_column :admin_scheduled_events, :has_subevents, :boolean
    # add_index :admin_scheduled_events, :has_subevents
    
    add_column :admin_scheduled_events, :main_event_id, :bigint
    add_index :admin_scheduled_events, :main_event_id
    add_foreign_key :admin_scheduled_events, :admin_scheduled_events, column: :main_event_id
  end
end

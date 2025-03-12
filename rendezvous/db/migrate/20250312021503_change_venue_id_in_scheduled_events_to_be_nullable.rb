class ChangeVenueIdInScheduledEventsToBeNullable < ActiveRecord::Migration[7.1]
  def change
    change_column_null :admin_scheduled_events, :admin_venue_id, true
  end
end

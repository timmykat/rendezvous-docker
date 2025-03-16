class RenameAllNewAdminModels < ActiveRecord::Migration[7.1]
  def change
    rename_table :admin_faqs, :faqs
    rename_table :admin_keyed_contents, :keyed_contents
    rename_table :admin_scheduled_events, :scheduled_events
    rename_table :admin_venues, :venues

    rename_column :scheduled_events, :admin_venue_id, :venue_id
  end
end

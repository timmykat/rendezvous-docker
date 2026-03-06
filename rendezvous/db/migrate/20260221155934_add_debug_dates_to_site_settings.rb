class AddDebugDatesToSiteSettings < ActiveRecord::Migration[7.2]
  def change
    add_column :site_settings, :debug_dates, :boolean
  end
end

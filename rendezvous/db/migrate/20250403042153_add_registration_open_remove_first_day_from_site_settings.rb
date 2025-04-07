class AddRegistrationOpenRemoveFirstDayFromSiteSettings < ActiveRecord::Migration[7.1]
  def change
    add_column :site_settings, :registration_is_open, :boolean
    remove_column :site_settings, :registration_open_date, :date
  end
end

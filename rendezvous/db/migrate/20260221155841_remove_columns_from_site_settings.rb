class RemoveColumnsFromSiteSettings < ActiveRecord::Migration[7.2]
  def change
    remove_column :site_settings, :days_duration, :integer
    remove_column :site_settings, :opening_day, :date
    remove_column :site_settings, :refund_date, :date
    remove_column :site_settings, :registration_close_date, :date
    remove_column :site_settings, :registration_fee, :decimal
    remove_column :site_settings, :show_registration_override, :boolean
    remove_column :site_settings, :user_testing, :boolean
    remove_column :site_settings, :vendor_fee, :decimal
  end
end

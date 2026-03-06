class AddTestDateToSiteSettings < ActiveRecord::Migration[7.2]
  def change
    add_column :site_settings, :debug_test_date, :date
  end
end

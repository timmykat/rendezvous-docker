class CreateSiteSettings < ActiveRecord::Migration[7.1]
  def change
    create_table :site_settings do |t|
      t.decimal :registration_fee, precision: 6, scale: 2
      t.date :opening_day
      t.integer :days_duration
      t.boolean :show_registration_override
      t.date :registration_open_date
      t.date :registration_close_date
      t.boolean :user_testing

      t.timestamps
    end
  end
end

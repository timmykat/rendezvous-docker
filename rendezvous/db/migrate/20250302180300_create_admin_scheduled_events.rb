class CreateAdminScheduledEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :admin_scheduled_events do |t|
      t.string :name
      t.string :day
      t.string :time
      t.string :short_description
      t.string :long_description
      t.integer :order
      t.references :admin_venue, null: false, foreign_key: true

      t.timestamps

      t.index ["day"], name: "index_scheduled_events_on_day"
      t.index ["order"], name: "index_scheduled_events_on_order"
    end
  end
end

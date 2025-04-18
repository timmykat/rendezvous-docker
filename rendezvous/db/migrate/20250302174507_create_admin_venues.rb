class CreateAdminVenues < ActiveRecord::Migration[7.1]
  def change
    create_table :admin_venues do |t|
      t.boolean :show_field_venue
      t.string :name
      t.string :address
      t.string :phone
      t.string :email
      t.string :details

      t.index ["show_field_venue"], name: "index_venues_on_show_field_venue"

      t.timestamps
    end
  end
end

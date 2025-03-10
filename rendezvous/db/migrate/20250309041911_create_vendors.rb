class CreateVendors < ActiveRecord::Migration[7.1]
  def change
    create_table :vendors do |t|
      t.string :name
      t.string :email
      t.string :website
      t.string :phone
      t.text :address

      t.timestamps
    end
  end
end

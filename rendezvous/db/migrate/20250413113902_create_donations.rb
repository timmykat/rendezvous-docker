class CreateDonations < ActiveRecord::Migration[7.1]
  def change
    create_table :donations do |t|
      t.integer :user_id, index: true
      t.integer :registration_id, index: true
      t.date    :date, index: true
      t.string  :first_name
      t.string  :last_name
      t.decimal :amount, precision: 6, scale: 2
      t.string  :status

      t.timestamps
    end
  end
end

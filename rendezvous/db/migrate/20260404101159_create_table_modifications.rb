class CreateTableModifications < ActiveRecord::Migration[7.2]
  def change
    create_table :modifications do |t|
      t.string :status, default: 'new', null: false
      t.integer :starting_adults, default: 0, null: false
      t.integer :starting_youths, default: 0, null: false
      t.integer :starting_children, default: 0, null: false
      t.integer :delta_adults, default: 0, null: false
      t.integer :delta_youths, default: 0, null: false
      t.integer :delta_children, default: 0, null: false
      t.integer :starting_lake_cruise, default: 0, null: false
      t.integer :delta_lake_cruise, default: 0, null: false
      t.decimal :new_attendee_fee, precision: 8, scale: 2, default: 0.0
      t.decimal :new_lake_cruise_fee, precision: 8, scale: 2, default: 0.0
      t.decimal :modification_total, precision: 8, scale: 2, default: 0.0
      t.decimal :new_total, precision: 8, scale: 2, default: 0.0
      t.references :registration, null: false, foreign_key: true, type: :integer

      t.timestamps
    end
  end
end

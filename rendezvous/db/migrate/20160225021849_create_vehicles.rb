class CreateVehicles < ActiveRecord::Migration
  def change
    create_table :vehicles do |t|
      t.string :year
      t.string :marque
      t.string :other_marque
      t.string :model
      t.string :other_model
      t.text :other_info
    end
    add_index :vehicles, :year
    add_index :vehicles, :marque
    add_index :vehicles, [:marque, :year, :model]
    add_index :vehicles, [:marque, :model]
    add_index :vehicles, :other_marque
    add_index :vehicles, :model
  end
end

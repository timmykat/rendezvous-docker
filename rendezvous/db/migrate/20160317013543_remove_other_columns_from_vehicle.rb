class RemoveOtherColumnsFromVehicle < ActiveRecord::Migration
  def up
    remove_column :vehicles, :other_marque
    remove_column :vehicles, :other_model    
  end
  
  def down
    add_column :vehicles, :other_marque, :string
    add_column :vehicles, :other_model, :string
    
    add_index  :vehicles, :other_marque
  end
end

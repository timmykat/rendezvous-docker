class AddCitroenvieToUser < ActiveRecord::Migration
  def change
    add_column :users, :citroenvie, :boolean
    add_index :users, :citroenvie
  end
end

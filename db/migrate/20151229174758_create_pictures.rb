class CreatePictures < ActiveRecord::Migration
  def change
    create_table :pictures do |t|
      t.references :user
      t.string :image
      t.string :caption
      t.string :credit
      t.integer :year

      t.timestamps null: false
    end
  end
end

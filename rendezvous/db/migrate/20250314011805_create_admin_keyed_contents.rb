class CreateAdminKeyedContents < ActiveRecord::Migration[7.1]
  def change
    create_table :admin_keyed_contents do |t|
      t.string :key
      t.text :content

      t.timestamps
    end
    add_index :admin_keyed_contents, :key
  end
end

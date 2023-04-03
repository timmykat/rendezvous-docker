class CreateEmailLinks < ActiveRecord::Migration[7.0]
  def change
    create_table :email_links do |t|
      t.string :token
      t.datetime :expires_at
      t.references :user
      
      t.timestamps
    end
    add_index :email_links, :token
  end
end

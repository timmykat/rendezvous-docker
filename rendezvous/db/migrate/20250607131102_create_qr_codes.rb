class CreateQrCodes < ActiveRecord::Migration[7.1]
  def change
    create_table :qr_codes do |t|
      t.string :code, null: false
      t.references :votable, polymorphic: true, null: true

      t.timestamps
    end
    add_index :qr_codes, :code, unique: true
  end
end

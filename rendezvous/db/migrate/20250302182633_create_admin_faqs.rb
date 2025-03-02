class CreateAdminFaqs < ActiveRecord::Migration[7.1]
  def change
    create_table :admin_faqs do |t|
      t.string :question
      t.string :response
      t.integer :order
      t.boolean :display, default: true

      t.timestamps

      t.index ["order"], name: "index_faqs_on_order"
      t.index ["display"], name: "index_faqs_on_display"
    end
  end
end

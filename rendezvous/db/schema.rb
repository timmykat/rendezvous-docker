# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_03_11_064101) do
  create_table "attendees", id: :integer, charset: "latin1", force: :cascade do |t|
    t.string "name"
    t.string "attendee_age", default: "adult"
    t.boolean "volunteer"
    t.boolean "sunday_dinner"
    t.integer "registration_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["attendee_age"], name: "index_attendees_on_attendee_age"
    t.index ["sunday_dinner"], name: "index_attendees_on_sunday_dinner"
    t.index ["volunteer"], name: "index_attendees_on_volunteer"
  end

  create_table "delayed_jobs", id: :integer, charset: "latin1", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at", precision: nil
    t.datetime "locked_at", precision: nil
    t.datetime "failed_at", precision: nil
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "main_pages", id: :integer, charset: "latin1", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "pictures", id: :integer, charset: "latin1", force: :cascade do |t|
    t.integer "user_id"
    t.string "image"
    t.string "caption"
    t.string "credit"
    t.integer "year"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "registrations", id: :integer, charset: "latin1", force: :cascade do |t|
    t.integer "number_of_adults"
    t.integer "number_of_children"
    t.decimal "registration_fee", precision: 6, scale: 2
    t.text "events"
    t.integer "user_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.decimal "paid_amount", precision: 6, scale: 2
    t.string "paid_method"
    t.datetime "paid_date", precision: nil
    t.string "year"
    t.string "invoice_number"
    t.decimal "donation", precision: 6, scale: 2
    t.string "cc_transaction_id"
    t.string "status"
    t.float "total"
    t.integer "number_of_seniors"
    t.index ["cc_transaction_id"], name: "index_registrations_on_cc_transaction_id"
    t.index ["invoice_number"], name: "index_registrations_on_invoice_number"
    t.index ["paid_amount"], name: "index_registrations_on_paid_amount"
    t.index ["paid_date"], name: "index_registrations_on_paid_date"
    t.index ["paid_method"], name: "index_registrations_on_paid_method"
    t.index ["status"], name: "index_registrations_on_status"
    t.index ["year"], name: "index_registrations_on_year"
  end

  create_table "transactions", id: :integer, charset: "latin1", force: :cascade do |t|
    t.string "transaction_method"
    t.string "transaction_type"
    t.string "cc_transaction_id"
    t.decimal "amount", precision: 6, scale: 2, default: "0.0"
    t.integer "registration_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["cc_transaction_id"], name: "index_transactions_on_cc_transaction_id"
    t.index ["transaction_method"], name: "index_transactions_on_transaction_method"
    t.index ["transaction_type"], name: "index_transactions_on_transaction_type"
  end

  create_table "users", id: :integer, charset: "latin1", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "provider"
    t.string "uid"
    t.integer "role_mask"
    t.string "first_name"
    t.string "last_name"
    t.boolean "receive_mailings", default: true
    t.string "address1"
    t.string "address2"
    t.string "city"
    t.string "state_or_province"
    t.string "postal_code"
    t.string "country"
    t.integer "roles_mask"
    t.boolean "citroenvie"
    t.index ["citroenvie"], name: "index_users_on_citroenvie"
    t.index ["country"], name: "index_users_on_country"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["first_name"], name: "index_users_on_first_name"
    t.index ["last_name"], name: "index_users_on_last_name"
    t.index ["provider"], name: "index_users_on_provider"
    t.index ["receive_mailings"], name: "index_users_on_receive_mailings"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["roles_mask"], name: "index_users_on_roles_mask"
    t.index ["state_or_province"], name: "index_users_on_state_or_province"
    t.index ["uid"], name: "index_users_on_uid"
  end

  create_table "vehicles", id: :integer, charset: "latin1", force: :cascade do |t|
    t.string "year"
    t.string "marque"
    t.string "model"
    t.text "other_info"
    t.integer "user_id"
    t.index ["marque", "model"], name: "index_vehicles_on_marque_and_model"
    t.index ["marque", "year", "model"], name: "index_vehicles_on_marque_and_year_and_model"
    t.index ["marque"], name: "index_vehicles_on_marque"
    t.index ["model"], name: "index_vehicles_on_model"
    t.index ["user_id"], name: "index_vehicles_on_user_id"
    t.index ["year"], name: "index_vehicles_on_year"
  end

  add_foreign_key "vehicles", "users"
end

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

ActiveRecord::Schema[7.2].define(version: 2026_03_15_112625) do
  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "annual_questions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "year"
    t.string "question"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["year"], name: "index_annual_questions_on_year"
  end

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

  create_table "ballot_selections", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "ballot_id"
    t.string "votable_type", null: false
    t.bigint "votable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ballot_id"], name: "index_ballot_selections_on_ballot_id"
    t.index ["votable_type", "votable_id"], name: "index_ballot_selections_on_votable"
  end

  create_table "ballots", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "year"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "voter_id", limit: 36
    t.index ["voter_id"], name: "index_ballots_on_voter_id"
    t.index ["year"], name: "index_ballots_on_year"
  end

  create_table "cart_items", charset: "latin1", force: :cascade do |t|
    t.bigint "merchitem_id"
    t.bigint "purchase_id"
    t.integer "number", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["merchitem_id"], name: "index_cart_items_on_merchitem_id"
    t.index ["purchase_id"], name: "index_cart_items_on_purchase_id"
  end

  create_table "delayed_jobs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "donations", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "user_id"
    t.integer "registration_id"
    t.date "date"
    t.string "first_name"
    t.string "last_name"
    t.decimal "amount", precision: 6, scale: 2
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "created_by_admin", default: false, null: false
    t.index ["date"], name: "index_donations_on_date"
    t.index ["registration_id"], name: "index_donations_on_registration_id"
    t.index ["user_id"], name: "index_donations_on_user_id"
  end

  create_table "email_links", charset: "latin1", force: :cascade do |t|
    t.string "token"
    t.datetime "expires_at"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_email_links_on_token"
    t.index ["user_id"], name: "index_email_links_on_user_id"
  end

  create_table "faqs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.text "question"
    t.text "response"
    t.integer "order"
    t.boolean "display", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["display"], name: "index_faqs_on_display"
    t.index ["order"], name: "index_faqs_on_order"
  end

  create_table "keyed_contents", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "key"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_keyed_contents_on_key", unique: true
  end

  create_table "main_pages", id: :integer, charset: "latin1", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "merchandise", charset: "latin1", force: :cascade do |t|
    t.string "sku"
    t.string "description"
    t.decimal "unit_cost", precision: 6, scale: 2
    t.decimal "sale_price", precision: 6, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sku"], name: "index_merchandise_on_sku"
  end

  create_table "merchitems", charset: "latin1", force: :cascade do |t|
    t.string "sku"
    t.string "size"
    t.integer "starting_inventory"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "merchandise_id"
    t.integer "remaining"
    t.index ["sku"], name: "index_merchitems_on_sku"
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

  create_table "purchases", charset: "latin1", force: :cascade do |t|
    t.text "untracked_merchandise"
    t.decimal "generic_amount", precision: 6, scale: 2
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "cc_transaction_id"
    t.decimal "transaction_amount", precision: 6, scale: 2
    t.decimal "cash_amount", precision: 6, scale: 2
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.string "postal_code"
    t.string "country"
    t.decimal "cash_check_paid", precision: 6, scale: 2, default: "0.0"
    t.decimal "total", precision: 6, scale: 2
    t.string "paid_method"
    t.index ["email"], name: "index_purchases_on_email"
  end

  create_table "qr_codes", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "code", null: false
    t.string "votable_type"
    t.bigint "votable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_qr_codes_on_code", unique: true
    t.index ["votable_type", "votable_id"], name: "index_qr_codes_on_votable"
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
    t.boolean "created_by_admin", default: false, null: false
    t.string "annual_answer"
    t.decimal "vendor_fee", precision: 6, scale: 2
    t.boolean "is_admin_created", default: false, null: false
    t.integer "number_of_youths"
    t.integer "sunday_lunch_number", default: 0, null: false
    t.integer "lake_cruise_number", default: 0, null: false
    t.decimal "lake_cruise_fee", precision: 6, scale: 2
    t.index ["cc_transaction_id"], name: "index_registrations_on_cc_transaction_id"
    t.index ["invoice_number"], name: "index_registrations_on_invoice_number"
    t.index ["paid_amount"], name: "index_registrations_on_paid_amount"
    t.index ["paid_date"], name: "index_registrations_on_paid_date"
    t.index ["paid_method"], name: "index_registrations_on_paid_method"
    t.index ["status"], name: "index_registrations_on_status"
    t.index ["year"], name: "index_registrations_on_year"
    t.check_constraint "(`lake_cruise_number` >= 0) and (`lake_cruise_number` <= 8)", name: "lake_cruise_limit"
    t.check_constraint "(`sunday_lunch_number` >= 0) and (`sunday_lunch_number` <= 8)", name: "sunday_lunch_limit"
  end

  create_table "registrations_vehicles", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "registration_id", null: false
    t.integer "vehicle_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["registration_id"], name: "index_registrations_vehicles_on_registration_id"
    t.index ["vehicle_id"], name: "index_registrations_vehicles_on_vehicle_id"
  end

  create_table "scheduled_events", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "day"
    t.string "time"
    t.text "short_description"
    t.text "long_description"
    t.integer "order"
    t.bigint "venue_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "has_subevents"
    t.bigint "main_event_id"
    t.boolean "extra_cost", default: false
    t.index ["day"], name: "index_scheduled_events_on_day"
    t.index ["has_subevents"], name: "index_scheduled_events_on_has_subevents"
    t.index ["main_event_id"], name: "index_scheduled_events_on_main_event_id"
    t.index ["order"], name: "index_scheduled_events_on_order"
    t.index ["venue_id"], name: "index_scheduled_events_on_venue_id"
  end

  create_table "site_settings", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "square_environment"
    t.boolean "registration_is_open"
    t.boolean "voting_on", default: false
    t.boolean "debug_dates"
    t.date "debug_test_date"
    t.boolean "login_on", default: false
  end

  create_table "square_transactions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "order_id"
    t.string "transaction_id"
    t.decimal "amount", precision: 6, scale: 2
    t.integer "user_id", null: false
    t.integer "registration_id"
    t.bigint "donation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["donation_id"], name: "index_square_transactions_on_donation_id"
    t.index ["registration_id"], name: "index_square_transactions_on_registration_id"
    t.index ["user_id"], name: "index_square_transactions_on_user_id"
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
    t.string "login_token"
    t.datetime "login_token_sent_at"
    t.boolean "is_testing", default: false
    t.boolean "recaptcha_whitelisted"
    t.datetime "last_active"
    t.boolean "is_admin_created", default: false
    t.index ["citroenvie"], name: "index_users_on_citroenvie"
    t.index ["country"], name: "index_users_on_country"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["first_name"], name: "index_users_on_first_name"
    t.index ["last_active"], name: "index_users_on_last_active"
    t.index ["last_name"], name: "index_users_on_last_name"
    t.index ["login_token"], name: "index_users_on_login_token", unique: true
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
    t.boolean "for_sale"
    t.string "code"
    t.index ["code"], name: "index_vehicles_on_code"
    t.index ["for_sale"], name: "index_vehicles_on_for_sale"
    t.index ["marque", "model"], name: "index_vehicles_on_marque_and_model"
    t.index ["marque", "year", "model"], name: "index_vehicles_on_marque_and_year_and_model"
    t.index ["marque"], name: "index_vehicles_on_marque"
    t.index ["model"], name: "index_vehicles_on_model"
    t.index ["user_id"], name: "index_vehicles_on_user_id"
    t.index ["year"], name: "index_vehicles_on_year"
  end

  create_table "vendors", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "website"
    t.string "phone"
    t.text "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "order"
    t.integer "owner_id"
    t.string "owner_display_name"
    t.index ["order"], name: "index_vendors_on_order"
    t.index ["owner_id"], name: "index_vendors_on_owner_id"
  end

  create_table "venues", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.boolean "show_field_venue"
    t.string "name"
    t.text "address"
    t.string "phone"
    t.string "email"
    t.text "details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "reservation_url"
    t.string "group_code"
    t.integer "rooms_available"
    t.date "close_date"
    t.string "type"
    t.string "website"
    t.index ["show_field_venue"], name: "index_venues_on_show_field_venue"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "ballot_selections", "ballots"
  add_foreign_key "registrations_vehicles", "registrations"
  add_foreign_key "registrations_vehicles", "vehicles"
  add_foreign_key "scheduled_events", "scheduled_events", column: "main_event_id"
  add_foreign_key "scheduled_events", "venues"
  add_foreign_key "square_transactions", "donations"
  add_foreign_key "square_transactions", "registrations"
  add_foreign_key "square_transactions", "users"
  add_foreign_key "vehicles", "users"
  add_foreign_key "vendors", "users", column: "owner_id"
end

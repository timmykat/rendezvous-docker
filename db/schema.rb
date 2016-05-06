# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160417170008) do

  create_table "attendees", force: :cascade do |t|
    t.string   "name",                       limit: 255
    t.string   "adult_or_child",             limit: 255, default: "adult"
    t.boolean  "volunteer"
    t.boolean  "sunday_dinner"
    t.integer  "rendezvous_registration_id", limit: 4
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
  end

  add_index "attendees", ["adult_or_child"], name: "index_attendees_on_adult_or_child", using: :btree
  add_index "attendees", ["sunday_dinner"], name: "index_attendees_on_sunday_dinner", using: :btree
  add_index "attendees", ["volunteer"], name: "index_attendees_on_volunteer", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,     default: 0, null: false
    t.integer  "attempts",   limit: 4,     default: 0, null: false
    t.text     "handler",    limit: 65535,             null: false
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "main_pages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pictures", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.string   "image",      limit: 255
    t.string   "caption",    limit: 255
    t.string   "credit",     limit: 255
    t.integer  "year",       limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "rendezvous_registrations", force: :cascade do |t|
    t.integer  "number_of_adults",   limit: 4
    t.integer  "number_of_children", limit: 4
    t.decimal  "registration_fee",                 precision: 6, scale: 2
    t.text     "events",             limit: 65535
    t.integer  "user_id",            limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "paid_amount",                      precision: 6, scale: 2
    t.string   "paid_method",        limit: 255
    t.datetime "paid_date"
    t.string   "year",               limit: 255
    t.string   "invoice_number",     limit: 255
    t.decimal  "donation",                         precision: 6, scale: 2
    t.string   "cc_transaction_id",  limit: 255
    t.string   "status",             limit: 255
    t.float    "total",              limit: 24
  end

  add_index "rendezvous_registrations", ["cc_transaction_id"], name: "index_rendezvous_registrations_on_cc_transaction_id", using: :btree
  add_index "rendezvous_registrations", ["invoice_number"], name: "index_rendezvous_registrations_on_invoice_number", using: :btree
  add_index "rendezvous_registrations", ["paid_amount"], name: "index_rendezvous_registrations_on_paid_amount", using: :btree
  add_index "rendezvous_registrations", ["paid_date"], name: "index_rendezvous_registrations_on_paid_date", using: :btree
  add_index "rendezvous_registrations", ["paid_method"], name: "index_rendezvous_registrations_on_paid_method", using: :btree
  add_index "rendezvous_registrations", ["status"], name: "index_rendezvous_registrations_on_status", using: :btree
  add_index "rendezvous_registrations", ["year"], name: "index_rendezvous_registrations_on_year", using: :btree

  create_table "transactions", force: :cascade do |t|
    t.string   "transaction_method",         limit: 255
    t.string   "transaction_type",           limit: 255
    t.string   "cc_transaction_id",          limit: 255
    t.decimal  "amount",                                 precision: 6, scale: 2, default: 0.0
    t.integer  "rendezvous_registration_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "transactions", ["cc_transaction_id"], name: "index_transactions_on_cc_transaction_id", using: :btree
  add_index "transactions", ["transaction_method"], name: "index_transactions_on_transaction_method", using: :btree
  add_index "transactions", ["transaction_type"], name: "index_transactions_on_transaction_type", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "",   null: false
    t.string   "encrypted_password",     limit: 255, default: "",   null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.string   "provider",               limit: 255
    t.string   "uid",                    limit: 255
    t.integer  "role_mask",              limit: 4
    t.string   "first_name",             limit: 255
    t.string   "last_name",              limit: 255
    t.string   "avatar",                 limit: 255
    t.boolean  "receive_mailings",                   default: true
    t.string   "address1",               limit: 255
    t.string   "address2",               limit: 255
    t.string   "city",                   limit: 255
    t.string   "state_or_province",      limit: 255
    t.string   "postal_code",            limit: 255
    t.string   "country",                limit: 255
    t.integer  "roles_mask",             limit: 4
    t.boolean  "citroenvie"
  end

  add_index "users", ["citroenvie"], name: "index_users_on_citroenvie", using: :btree
  add_index "users", ["country"], name: "index_users_on_country", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["first_name"], name: "index_users_on_first_name", using: :btree
  add_index "users", ["last_name"], name: "index_users_on_last_name", using: :btree
  add_index "users", ["provider"], name: "index_users_on_provider", using: :btree
  add_index "users", ["receive_mailings"], name: "index_users_on_receive_mailings", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["roles_mask"], name: "index_users_on_roles_mask", using: :btree
  add_index "users", ["state_or_province"], name: "index_users_on_state_or_province", using: :btree
  add_index "users", ["uid"], name: "index_users_on_uid", using: :btree

  create_table "vehicles", force: :cascade do |t|
    t.string  "year",       limit: 255
    t.string  "marque",     limit: 255
    t.string  "model",      limit: 255
    t.text    "other_info", limit: 65535
    t.integer "user_id",    limit: 4
  end

  add_index "vehicles", ["marque", "model"], name: "index_vehicles_on_marque_and_model", using: :btree
  add_index "vehicles", ["marque", "year", "model"], name: "index_vehicles_on_marque_and_year_and_model", using: :btree
  add_index "vehicles", ["marque"], name: "index_vehicles_on_marque", using: :btree
  add_index "vehicles", ["model"], name: "index_vehicles_on_model", using: :btree
  add_index "vehicles", ["user_id"], name: "index_vehicles_on_user_id", using: :btree
  add_index "vehicles", ["year"], name: "index_vehicles_on_year", using: :btree

  add_foreign_key "vehicles", "users"
end

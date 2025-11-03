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

ActiveRecord::Schema[8.1].define(version: 2025_10_22_105501) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "billing_checklists", force: :cascade do |t|
    t.bigint "billing_id", null: false
    t.bigint "charge_checklist_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["billing_id", "charge_checklist_id"], name: "index_billing_checklists_on_billing_id_and_charge_checklist_id", unique: true
    t.index ["billing_id"], name: "index_billing_checklists_on_billing_id"
    t.index ["charge_checklist_id"], name: "index_billing_checklists_on_charge_checklist_id"
  end

  create_table "billing_lines", force: :cascade do |t|
    t.integer "amount_cents", default: 0, null: false
    t.bigint "billing_id", null: false
    t.string "category"
    t.bigint "charge_checklist_id", null: false
    t.bigint "charge_checklist_item_id", null: false
    t.datetime "created_at", null: false
    t.date "date"
    t.string "dosage"
    t.string "frequency"
    t.string "item_code"
    t.bigint "medicine_id"
    t.jsonb "metadata", default: {}, null: false
    t.string "name"
    t.integer "quantity", default: 0, null: false
    t.string "route"
    t.string "unit"
    t.integer "unit_price_cents", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["billing_id", "charge_checklist_item_id"], name: "idx_unique_billing_line_per_cc_item", unique: true
    t.index ["billing_id", "date"], name: "index_billing_lines_on_billing_id_and_date"
    t.index ["billing_id"], name: "index_billing_lines_on_billing_id"
    t.index ["charge_checklist_id"], name: "index_billing_lines_on_charge_checklist_id"
    t.index ["charge_checklist_item_id"], name: "index_billing_lines_on_charge_checklist_item_id"
    t.index ["item_code"], name: "index_billing_lines_on_item_code"
    t.index ["medicine_id"], name: "index_billing_lines_on_medicine_id"
  end

  create_table "billings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "discount_cents", default: 0, null: false
    t.jsonb "metadata", default: {}, null: false
    t.text "notes"
    t.bigint "patient_id", null: false
    t.date "period_end"
    t.date "period_start"
    t.date "statement_date"
    t.string "statement_number", null: false
    t.string "status", default: "draft", null: false
    t.integer "subtotal_cents", default: 0, null: false
    t.integer "total_cents", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["patient_id", "statement_date"], name: "index_billings_on_patient_id_and_statement_date"
    t.index ["patient_id"], name: "index_billings_on_patient_id"
    t.index ["statement_number"], name: "index_billings_on_statement_number", unique: true
  end

  create_table "charge_categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "key"
    t.string "name"
    t.integer "position"
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_charge_categories_on_key", unique: true
  end

  create_table "charge_checklist_items", force: :cascade do |t|
    t.bigint "charge_checklist_id", null: false
    t.bigint "charge_item_id", null: false
    t.datetime "created_at", null: false
    t.bigint "medicine_id"
    t.jsonb "metadata", default: {}
    t.integer "quantity"
    t.integer "total_cents"
    t.integer "unit_price_cents"
    t.datetime "updated_at", null: false
    t.index ["charge_checklist_id", "charge_item_id"], name: "idx_on_charge_checklist_id_charge_item_id_d5f34a8668"
    t.index ["charge_checklist_id"], name: "index_charge_checklist_items_on_charge_checklist_id"
    t.index ["charge_item_id"], name: "index_charge_checklist_items_on_charge_item_id"
    t.index ["medicine_id"], name: "index_charge_checklist_items_on_medicine_id"
  end

  create_table "charge_checklists", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "issued", default: ""
    t.jsonb "metadata", default: {}
    t.text "notes"
    t.bigint "patient_id", null: false
    t.date "performed_on"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["patient_id"], name: "index_charge_checklists_on_patient_id"
    t.index ["user_id"], name: "index_charge_checklists_on_user_id"
  end

  create_table "charge_items", force: :cascade do |t|
    t.boolean "active", default: true
    t.bigint "charge_category_id", null: false
    t.datetime "created_at", null: false
    t.integer "default_price_cents"
    t.integer "inventory_item_id"
    t.jsonb "metadata", default: {}
    t.string "name"
    t.integer "position"
    t.string "unit"
    t.datetime "updated_at", null: false
    t.index ["charge_category_id", "position"], name: "index_charge_items_on_charge_category_id_and_position"
    t.index ["charge_category_id"], name: "index_charge_items_on_charge_category_id"
  end

  create_table "medicines", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "dosage"
    t.string "drug_name"
    t.string "form"
    t.string "frequency"
    t.string "generic_name"
    t.string "item_code"
    t.jsonb "metadata", default: {}
    t.text "notes"
    t.integer "qty"
    t.string "route"
    t.string "strength"
    t.string "unit"
    t.integer "unit_price_cents", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["item_code"], name: "index_medicines_on_item_code", unique: true
  end

  create_table "patients", force: :cascade do |t|
    t.text "address"
    t.string "city"
    t.datetime "created_at", null: false
    t.date "date_of_birth"
    t.string "email"
    t.string "first_name"
    t.string "gender"
    t.string "last_name"
    t.string "phone_number"
    t.datetime "updated_at", null: false
  end

  create_table "roles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description"
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "first_name"
    t.string "gender"
    t.string "last_name"
    t.string "middle_name"
    t.string "password_digest", null: false
    t.bigint "role_id", null: false
    t.string "status", default: "Active"
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["role_id"], name: "index_users_on_role_id"
  end

  add_foreign_key "billing_checklists", "billings"
  add_foreign_key "billing_checklists", "charge_checklists"
  add_foreign_key "billing_lines", "billings"
  add_foreign_key "billing_lines", "charge_checklist_items"
  add_foreign_key "billing_lines", "charge_checklists"
  add_foreign_key "billing_lines", "medicines"
  add_foreign_key "billings", "patients"
  add_foreign_key "charge_checklist_items", "charge_checklists"
  add_foreign_key "charge_checklist_items", "charge_items"
  add_foreign_key "charge_checklist_items", "medicines"
  add_foreign_key "charge_checklists", "patients"
  add_foreign_key "charge_checklists", "users"
  add_foreign_key "charge_items", "charge_categories"
  add_foreign_key "sessions", "users"
  add_foreign_key "users", "roles"
end

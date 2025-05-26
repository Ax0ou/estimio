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

ActiveRecord::Schema[7.1].define(version: 2025_05_26_120731) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ai_messages", force: :cascade do |t|
    t.string "description"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "clients", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "craftmen", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "siret"
    t.string "company_name"
    t.string "address"
    t.string "phone_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "quotes", force: :cascade do |t|
    t.bigint "craftman_id", null: false
    t.bigint "client_id", null: false
    t.string "title"
    t.string "project_type"
    t.bigint "ai_message_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ai_message_id"], name: "index_quotes_on_ai_message_id"
    t.index ["client_id"], name: "index_quotes_on_client_id"
    t.index ["craftman_id"], name: "index_quotes_on_craftman_id"
  end

  add_foreign_key "quotes", "ai_messages"
  add_foreign_key "quotes", "clients"
  add_foreign_key "quotes", "craftmen"
end

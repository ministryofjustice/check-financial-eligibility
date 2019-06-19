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

ActiveRecord::Schema.define(version: 2019_06_19_092242) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "assessments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "client_reference_id"
    t.inet "remote_ip", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "submission_date", null: false
    t.string "matter_proceeding_type", null: false
    t.index ["client_reference_id"], name: "index_assessments_on_client_reference_id"
  end

  create_table "dependent_income_receipts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "dependent_id"
    t.date "date_of_payment"
    t.decimal "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "dependents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "assessment_id"
    t.date "date_of_birth"
    t.boolean "in_full_time_education"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "properties", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "assessment_id", null: false
    t.decimal "value"
    t.decimal "outstanding_mortgage"
    t.decimal "percentage_owned"
    t.boolean "main_home"
    t.boolean "shared_with_housing_assoc"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assessment_id"], name: "index_properties_on_assessment_id"
  end

  create_table "statuses", force: :cascade do |t|
    t.string "response"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "properties", "assessments"
end

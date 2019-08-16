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

ActiveRecord::Schema.define(version: 2019_08_20_105503) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "applicants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "assessment_id", null: false
    t.date "date_of_birth"
    t.string "involvement_type"
    t.boolean "has_partner_opponent"
    t.boolean "receives_qualifying_benefit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assessment_id"], name: "index_applicants_on_assessment_id"
  end

  create_table "assessments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "client_reference_id"
    t.inet "remote_ip", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "submission_date", null: false
    t.string "matter_proceeding_type", null: false
    t.string "assessment_result", default: "pending", null: false
    t.index ["client_reference_id"], name: "index_assessments_on_client_reference_id"
  end

  create_table "benefit_receipts", force: :cascade do |t|
    t.uuid "assessment_id", null: false
    t.string "benefit_name"
    t.date "payment_date"
    t.decimal "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assessment_id"], name: "index_benefit_receipts_on_assessment_id"
  end

  create_table "capital_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "capital_summary_id"
    t.string "type", null: false
    t.string "description", null: false
    t.decimal "value", default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["capital_summary_id"], name: "index_capital_items_on_capital_summary_id"
  end

  create_table "capital_summaries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "assessment_id"
    t.decimal "total_liquid", default: "0.0", null: false
    t.decimal "total_non_liquid", default: "0.0", null: false
    t.decimal "total_vehicle", default: "0.0", null: false
    t.decimal "total_property", default: "0.0", null: false
    t.decimal "total_mortgage_allowance", default: "0.0", null: false
    t.decimal "total_capital", default: "0.0", null: false
    t.decimal "pensioner_capital_disregard", default: "0.0", null: false
    t.decimal "assessed_capital", default: "0.0", null: false
    t.decimal "capital_contribution", default: "0.0", null: false
    t.decimal "lower_threshold", default: "0.0", null: false
    t.decimal "upper_threshold", default: "0.0", null: false
    t.string "capital_assessment_result", default: "pending", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assessment_id"], name: "index_capital_summaries_on_assessment_id"
  end

  create_table "dependants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "assessment_id"
    t.date "date_of_birth"
    t.boolean "in_full_time_education"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "relationship"
    t.decimal "monthly_income"
    t.decimal "assets_value"
  end

  create_table "outgoings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "outgoing_type"
    t.date "payment_date"
    t.decimal "amount"
    t.uuid "assessment_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assessment_id"], name: "index_outgoings_on_assessment_id"
  end

  create_table "properties", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "value"
    t.decimal "outstanding_mortgage"
    t.decimal "percentage_owned"
    t.boolean "main_home"
    t.boolean "shared_with_housing_assoc"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "capital_summary_id"
    t.decimal "transaction_allowance", default: "0.0", null: false
    t.decimal "allowable_outstanding_mortgage", default: "0.0", null: false
    t.decimal "net_value", default: "0.0", null: false
    t.decimal "net_equity", default: "0.0", null: false
    t.decimal "assessed_equity", default: "0.0", null: false
    t.decimal "main_home_equity_disregard", default: "0.0", null: false
    t.index ["capital_summary_id"], name: "index_properties_on_capital_summary_id"
  end

  create_table "statuses", force: :cascade do |t|
    t.string "response"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "vehicles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "value"
    t.decimal "loan_amount_outstanding"
    t.date "date_of_purchase"
    t.boolean "in_regular_use"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "capital_summary_id"
    t.boolean "included_in_assessment", default: false, null: false
    t.decimal "assessed_value", default: "0.0", null: false
    t.index ["capital_summary_id"], name: "index_vehicles_on_capital_summary_id"
  end

  create_table "wage_slips", force: :cascade do |t|
    t.uuid "assessment_id", null: false
    t.date "payment_date"
    t.decimal "gross_pay"
    t.decimal "paye"
    t.decimal "nic"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assessment_id"], name: "index_wage_slips_on_assessment_id"
  end

  add_foreign_key "applicants", "assessments"
  add_foreign_key "benefit_receipts", "assessments"
  add_foreign_key "capital_items", "capital_summaries"
  add_foreign_key "capital_summaries", "assessments"
  add_foreign_key "outgoings", "assessments"
  add_foreign_key "properties", "capital_summaries"
  add_foreign_key "vehicles", "capital_summaries"
  add_foreign_key "wage_slips", "assessments"
end

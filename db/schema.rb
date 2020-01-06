# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_01_06_120428) do

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
    t.boolean "self_employed", default: false
    t.index ["assessment_id"], name: "index_applicants_on_assessment_id"
  end

  create_table "assessment_errors", force: :cascade do |t|
    t.uuid "assessment_id", null: false
    t.uuid "record_id"
    t.string "record_type"
    t.string "error_message"
    t.index ["assessment_id"], name: "index_assessment_errors_on_assessment_id"
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

  create_table "disposable_income_summaries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "assessment_id", null: false
    t.decimal "childcare", default: "0.0", null: false
    t.decimal "dependant_allowance", default: "0.0", null: false
    t.decimal "maintenance", default: "0.0", null: false
    t.decimal "gross_housing_costs", default: "0.0", null: false
    t.decimal "total_outgoings_and_allowances", default: "0.0", null: false
    t.decimal "total_disposable_income", default: "0.0", null: false
    t.decimal "lower_threshold", default: "0.0", null: false
    t.decimal "upper_threshold", default: "0.0", null: false
    t.string "assessment_result", default: "pending", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.decimal "net_housing_costs", default: "0.0"
    t.decimal "housing_benefit", default: "0.0"
    t.decimal "income_contribution", default: "0.0"
    t.index ["assessment_id"], name: "index_disposable_income_summaries_on_assessment_id"
  end

  create_table "gross_income_summaries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "assessment_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.decimal "upper_threshold", default: "0.0", null: false
    t.decimal "monthly_other_income"
    t.boolean "assessment_error", default: false
    t.string "assessment_result", default: "pending", null: false
    t.decimal "monthly_state_benefits", default: "0.0", null: false
    t.decimal "total_gross_income", default: "0.0"
    t.index ["assessment_id"], name: "index_gross_income_summaries_on_assessment_id"
  end

  create_table "other_income_payments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "other_income_source_id", null: false
    t.date "payment_date", null: false
    t.decimal "amount", null: false
    t.boolean "assessment_error", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["other_income_source_id"], name: "index_other_income_payments_on_other_income_source_id"
  end

  create_table "other_income_sources", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "gross_income_summary_id", null: false
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.decimal "monthly_income"
    t.boolean "assessment_error", default: false
    t.index ["gross_income_summary_id"], name: "index_other_income_sources_on_gross_income_summary_id"
  end

  create_table "outgoings", force: :cascade do |t|
    t.uuid "disposable_income_summary_id", null: false
    t.string "type", null: false
    t.date "payment_date", null: false
    t.decimal "amount", null: false
    t.string "housing_cost_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["disposable_income_summary_id"], name: "index_outgoings_on_disposable_income_summary_id"
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

  create_table "state_benefit_payments", force: :cascade do |t|
    t.uuid "state_benefit_id", null: false
    t.date "payment_date", null: false
    t.decimal "amount", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["state_benefit_id"], name: "index_state_benefit_payments_on_state_benefit_id"
  end

  create_table "state_benefit_types", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "label"
    t.text "name"
    t.boolean "exclude_from_gross_income"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "dwp_code"
    t.index ["dwp_code"], name: "index_state_benefit_types_on_dwp_code", unique: true
    t.index ["label"], name: "index_state_benefit_types_on_label", unique: true
  end

  create_table "state_benefits", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "gross_income_summary_id", null: false
    t.uuid "state_benefit_type_id", null: false
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.decimal "monthly_value", default: "0.0", null: false
    t.index ["gross_income_summary_id"], name: "index_state_benefits_on_gross_income_summary_id"
    t.index ["state_benefit_type_id"], name: "index_state_benefits_on_state_benefit_type_id"
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

  add_foreign_key "applicants", "assessments"
  add_foreign_key "assessment_errors", "assessments"
  add_foreign_key "capital_items", "capital_summaries"
  add_foreign_key "capital_summaries", "assessments"
  add_foreign_key "disposable_income_summaries", "assessments"
  add_foreign_key "gross_income_summaries", "assessments"
  add_foreign_key "other_income_payments", "other_income_sources"
  add_foreign_key "other_income_sources", "gross_income_summaries"
  add_foreign_key "outgoings", "disposable_income_summaries"
  add_foreign_key "properties", "capital_summaries"
  add_foreign_key "state_benefit_payments", "state_benefits"
  add_foreign_key "state_benefits", "gross_income_summaries"
  add_foreign_key "state_benefits", "state_benefit_types"
  add_foreign_key "vehicles", "capital_summaries"
end

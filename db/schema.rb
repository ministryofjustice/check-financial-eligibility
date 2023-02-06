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

ActiveRecord::Schema[7.0].define(version: 2023_01_31_154602) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "applicants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "assessment_id", null: false
    t.date "date_of_birth"
    t.string "involvement_type"
    t.boolean "has_partner_opponent"
    t.boolean "receives_qualifying_benefit"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "self_employed", default: false
    t.boolean "employed"
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
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.date "submission_date", null: false
    t.string "assessment_result", default: "pending", null: false
    t.text "remarks"
    t.string "version"
    t.integer "level_of_representation", default: 0
    t.index ["client_reference_id"], name: "index_assessments_on_client_reference_id"
  end

  create_table "bank_holidays", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "dates"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "capital_items", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "capital_summary_id"
    t.string "type", null: false
    t.string "description", null: false
    t.decimal "value", default: "0.0", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "subject_matter_of_dispute"
    t.index ["capital_summary_id"], name: "index_capital_items_on_capital_summary_id"
  end

  create_table "capital_summaries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "assessment_id"
    t.decimal "total_liquid", default: "0.0", null: false
    t.decimal "total_non_liquid", default: "0.0", null: false
    t.decimal "total_property", default: "0.0", null: false
    t.decimal "total_mortgage_allowance", default: "0.0", null: false
    t.decimal "total_capital", default: "0.0", null: false
    t.decimal "pensioner_capital_disregard", default: "0.0", null: false
    t.decimal "assessed_capital", default: "0.0", null: false
    t.decimal "capital_contribution", default: "0.0", null: false
    t.decimal "lower_threshold", default: "0.0", null: false
    t.decimal "upper_threshold", default: "0.0", null: false
    t.string "assessment_result", default: "pending", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.decimal "subject_matter_of_dispute_disregard", default: "0.0", null: false
    t.string "type", default: "ApplicantCapitalSummary"
    t.decimal "combined_assessed_capital"
    t.index ["assessment_id"], name: "index_capital_summaries_on_assessment_id"
  end

  create_table "cash_transaction_categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "gross_income_summary_id"
    t.string "operation"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["gross_income_summary_id", "name", "operation"], name: "index_cash_transaction_categories_uniqueness", unique: true
    t.index ["gross_income_summary_id"], name: "index_cash_transaction_categories_on_gross_income_summary_id"
  end

  create_table "cash_transactions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "cash_transaction_category_id"
    t.date "date"
    t.decimal "amount"
    t.string "client_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cash_transaction_category_id"], name: "index_cash_transactions_on_cash_transaction_category_id"
  end

  create_table "dependants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "assessment_id"
    t.date "date_of_birth"
    t.boolean "in_full_time_education"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "relationship"
    t.decimal "monthly_income"
    t.decimal "assets_value"
    t.decimal "dependant_allowance", default: "0.0"
    t.string "type", default: "ApplicantDependant"
  end

  create_table "disposable_income_summaries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "assessment_id", null: false
    t.decimal "dependant_allowance", default: "0.0", null: false
    t.decimal "gross_housing_costs", default: "0.0", null: false
    t.decimal "total_outgoings_and_allowances", default: "0.0", null: false
    t.decimal "total_disposable_income", default: "0.0", null: false
    t.decimal "lower_threshold", default: "0.0", null: false
    t.decimal "upper_threshold", default: "0.0", null: false
    t.string "assessment_result", default: "pending", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "net_housing_costs", default: "0.0"
    t.decimal "housing_benefit", default: "0.0"
    t.decimal "income_contribution", default: "0.0"
    t.decimal "child_care_all_sources", default: "0.0"
    t.decimal "maintenance_out_all_sources", default: "0.0"
    t.decimal "rent_or_mortgage_all_sources", default: "0.0"
    t.decimal "legal_aid_all_sources", default: "0.0"
    t.decimal "child_care_bank", default: "0.0"
    t.decimal "maintenance_out_bank", default: "0.0"
    t.decimal "rent_or_mortgage_bank", default: "0.0"
    t.decimal "legal_aid_bank", default: "0.0"
    t.decimal "child_care_cash", default: "0.0"
    t.decimal "maintenance_out_cash", default: "0.0"
    t.decimal "rent_or_mortgage_cash", default: "0.0"
    t.decimal "legal_aid_cash", default: "0.0"
    t.decimal "employment_income_deductions", default: "0.0", null: false
    t.decimal "fixed_employment_allowance", default: "0.0", null: false
    t.decimal "tax", default: "0.0", null: false
    t.decimal "national_insurance", default: "0.0", null: false
    t.string "type", default: "ApplicantDisposableIncomeSummary"
    t.decimal "combined_total_disposable_income"
    t.decimal "combined_total_outgoings_and_allowances"
    t.index ["assessment_id"], name: "index_disposable_income_summaries_on_assessment_id"
  end

  create_table "eligibilities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "parent_id", null: false
    t.string "type"
    t.string "proceeding_type_code", null: false
    t.decimal "lower_threshold"
    t.decimal "upper_threshold"
    t.string "assessment_result", default: "pending", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id", "type", "proceeding_type_code"], name: "eligibilities_unique_type_ptc", unique: true
  end

  create_table "employment_payments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "employment_id"
    t.date "date", null: false
    t.decimal "gross_income", default: "0.0", null: false
    t.decimal "benefits_in_kind", default: "0.0", null: false
    t.decimal "tax", default: "0.0", null: false
    t.decimal "national_insurance", default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "client_id", null: false
    t.decimal "gross_income_monthly_equiv", default: "0.0", null: false
    t.decimal "tax_monthly_equiv", default: "0.0", null: false
    t.decimal "national_insurance_monthly_equiv", default: "0.0", null: false
    t.index ["employment_id"], name: "index_employment_payments_on_employment_id"
  end

  create_table "employments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "assessment_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "monthly_gross_income", default: "0.0", null: false
    t.decimal "monthly_benefits_in_kind", default: "0.0", null: false
    t.decimal "monthly_tax", default: "0.0", null: false
    t.decimal "monthly_national_insurance", default: "0.0", null: false
    t.string "client_id", null: false
    t.string "calculation_method"
    t.string "type", default: "ApplicantEmployment"
    t.index ["assessment_id"], name: "index_employments_on_assessment_id"
  end

  create_table "explicit_remarks", force: :cascade do |t|
    t.uuid "assessment_id"
    t.string "category"
    t.string "remark"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "gross_income_summaries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "assessment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "upper_threshold", default: "0.0", null: false
    t.decimal "monthly_other_income"
    t.boolean "assessment_error", default: false
    t.string "assessment_result", default: "pending", null: false
    t.decimal "monthly_state_benefits", default: "0.0", null: false
    t.decimal "total_gross_income", default: "0.0"
    t.decimal "student_loan", default: "0.0"
    t.decimal "monthly_student_loan"
    t.decimal "benefits_all_sources", default: "0.0"
    t.decimal "friends_or_family_all_sources", default: "0.0"
    t.decimal "maintenance_in_all_sources", default: "0.0"
    t.decimal "property_or_lodger_all_sources", default: "0.0"
    t.decimal "pension_all_sources", default: "0.0"
    t.decimal "benefits_bank", default: "0.0"
    t.decimal "friends_or_family_bank", default: "0.0"
    t.decimal "maintenance_in_bank", default: "0.0"
    t.decimal "property_or_lodger_bank", default: "0.0"
    t.decimal "pension_bank", default: "0.0"
    t.decimal "benefits_cash", default: "0.0"
    t.decimal "friends_or_family_cash", default: "0.0"
    t.decimal "maintenance_in_cash", default: "0.0"
    t.decimal "property_or_lodger_cash", default: "0.0"
    t.decimal "pension_cash", default: "0.0"
    t.decimal "gross_employment_income", default: "0.0", null: false
    t.decimal "benefits_in_kind", default: "0.0", null: false
    t.decimal "unspecified_source", default: "0.0"
    t.decimal "monthly_unspecified_source"
    t.string "type", default: "ApplicantGrossIncomeSummary"
    t.decimal "combined_total_gross_income"
    t.index ["assessment_id"], name: "index_gross_income_summaries_on_assessment_id"
  end

  create_table "irregular_income_payments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "gross_income_summary_id", null: false
    t.string "income_type", null: false
    t.string "frequency", null: false
    t.decimal "amount", default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["gross_income_summary_id", "income_type"], name: "irregular_income_payments_unique", unique: true
    t.index ["gross_income_summary_id"], name: "index_irregular_income_payments_on_gross_income_summary_id"
  end

  create_table "other_income_payments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "other_income_source_id", null: false
    t.date "payment_date", null: false
    t.decimal "amount", null: false
    t.boolean "assessment_error", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "client_id"
    t.index ["other_income_source_id"], name: "index_other_income_payments_on_other_income_source_id"
  end

  create_table "other_income_sources", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "gross_income_summary_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "client_id"
    t.index ["disposable_income_summary_id"], name: "index_outgoings_on_disposable_income_summary_id"
  end

  create_table "partners", force: :cascade do |t|
    t.uuid "assessment_id", null: false
    t.date "date_of_birth"
    t.boolean "employed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assessment_id"], name: "index_partners_on_assessment_id"
  end

  create_table "proceeding_types", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "assessment_id"
    t.string "ccms_code", null: false
    t.string "client_involvement_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "gross_income_upper_threshold"
    t.decimal "disposable_income_upper_threshold"
    t.decimal "capital_upper_threshold"
    t.index ["assessment_id", "ccms_code"], name: "index_proceeding_types_on_assessment_id_and_ccms_code", unique: true
    t.index ["assessment_id"], name: "index_proceeding_types_on_assessment_id"
  end

  create_table "properties", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "value"
    t.decimal "outstanding_mortgage"
    t.decimal "percentage_owned"
    t.boolean "main_home"
    t.boolean "shared_with_housing_assoc"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.uuid "capital_summary_id"
    t.decimal "transaction_allowance", default: "0.0", null: false
    t.decimal "allowable_outstanding_mortgage", default: "0.0", null: false
    t.decimal "net_value", default: "0.0", null: false
    t.decimal "net_equity", default: "0.0", null: false
    t.decimal "assessed_equity"
    t.decimal "main_home_equity_disregard", default: "0.0", null: false
    t.boolean "subject_matter_of_dispute"
    t.index ["capital_summary_id"], name: "index_properties_on_capital_summary_id"
  end

  create_table "regular_transactions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "gross_income_summary_id", null: false
    t.string "category"
    t.string "operation"
    t.decimal "amount"
    t.string "frequency"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["gross_income_summary_id"], name: "index_regular_transactions_on_gross_income_summary_id"
  end

  create_table "request_logs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "request_method"
    t.string "endpoint"
    t.string "assessment_id"
    t.string "params"
    t.integer "http_status"
    t.string "response"
    t.decimal "duration"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "state_benefit_payments", force: :cascade do |t|
    t.uuid "state_benefit_id", null: false
    t.date "payment_date", null: false
    t.decimal "amount", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "client_id"
    t.json "flags"
    t.index ["state_benefit_id"], name: "index_state_benefit_payments_on_state_benefit_id"
  end

  create_table "state_benefit_types", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "label"
    t.text "name"
    t.boolean "exclude_from_gross_income"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "dwp_code"
    t.string "category"
    t.index ["dwp_code"], name: "index_state_benefit_types_on_dwp_code", unique: true
    t.index ["label"], name: "index_state_benefit_types_on_label", unique: true
  end

  create_table "state_benefits", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "gross_income_summary_id", null: false
    t.uuid "state_benefit_type_id", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "monthly_value", default: "0.0", null: false
    t.index ["gross_income_summary_id"], name: "index_state_benefits_on_gross_income_summary_id"
    t.index ["state_benefit_type_id"], name: "index_state_benefits_on_state_benefit_type_id"
  end

  create_table "vehicles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "value"
    t.decimal "loan_amount_outstanding"
    t.date "date_of_purchase"
    t.boolean "in_regular_use"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.uuid "capital_summary_id"
    t.boolean "included_in_assessment", default: false, null: false
    t.decimal "assessed_value"
    t.boolean "subject_matter_of_dispute"
    t.index ["capital_summary_id"], name: "index_vehicles_on_capital_summary_id"
  end

  add_foreign_key "applicants", "assessments"
  add_foreign_key "assessment_errors", "assessments"
  add_foreign_key "capital_items", "capital_summaries"
  add_foreign_key "capital_summaries", "assessments"
  add_foreign_key "cash_transaction_categories", "gross_income_summaries"
  add_foreign_key "cash_transactions", "cash_transaction_categories"
  add_foreign_key "disposable_income_summaries", "assessments"
  add_foreign_key "employment_payments", "employments"
  add_foreign_key "employments", "assessments"
  add_foreign_key "gross_income_summaries", "assessments"
  add_foreign_key "irregular_income_payments", "gross_income_summaries"
  add_foreign_key "other_income_payments", "other_income_sources"
  add_foreign_key "other_income_sources", "gross_income_summaries"
  add_foreign_key "outgoings", "disposable_income_summaries"
  add_foreign_key "partners", "assessments"
  add_foreign_key "proceeding_types", "assessments"
  add_foreign_key "properties", "capital_summaries"
  add_foreign_key "regular_transactions", "gross_income_summaries"
  add_foreign_key "state_benefit_payments", "state_benefits"
  add_foreign_key "state_benefits", "gross_income_summaries"
  add_foreign_key "state_benefits", "state_benefit_types"
  add_foreign_key "vehicles", "capital_summaries"
end

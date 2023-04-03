class RemoveAndUpdateTimestampColumns < ActiveRecord::Migration[7.0]
  RESOURCES = %i[
    applicants
    bank_holidays
    capital_items
    capital_summaries
    cash_transaction_categories
    cash_transactions
    dependants
    disposable_income_summaries
    eligibilities
    employment_payments
    employments
    explicit_remarks
    gross_income_summaries
    irregular_income_payments
    other_income_payments
    other_income_sources
    outgoings
    partners
    proceeding_types
    properties
    regular_transactions
    request_logs
    state_benefit_payments
    state_benefit_types
    state_benefits
    vehicles
  ].freeze

  def up
    change_table :assessments, bulk: true do |t|
      t.change :created_at, :date
      t.change :updated_at, :date
    end

    RESOURCES.each do |resource|
      change_table resource, bulk: true do |t|
        t.remove :created_at, :updated_at, type: :datetime
      end
    end
  end

  def down
    change_table :assessments, bulk: true do |t|
      t.change :created_at, :datetime, precision: nil, null: false
      t.change :updated_at, :datetime, precision: nil, null: false
    end

    RESOURCES.each do |resource|
      change_table resource, bulk: true do |t|
        t.column :created_at, :datetime, null: %i[state_benefit_types].any?(resource)
        t.column :updated_at, :datetime, null: %i[state_benefit_types].any?(resource)
      end
    end
  end
end

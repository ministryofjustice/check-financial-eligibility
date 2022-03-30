class AddTaxMonthlyEquivToEmploymentPayment < ActiveRecord::Migration[7.0]
  change_table :employment_payments, bulk: true do |t|
    t.decimal :tax_monthly_equiv, default: 0.0, null: false
    t.decimal :national_insurance_monthly_equiv, default: 0.0, null: false
  end
end

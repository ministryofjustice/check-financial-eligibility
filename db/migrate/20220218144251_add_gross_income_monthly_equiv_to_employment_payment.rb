class AddGrossIncomeMonthlyEquivToEmploymentPayment < ActiveRecord::Migration[6.1]
  def change
    add_column :employment_payments, :gross_income_monthly_equiv, :decimal, default: 0.0, null: false
  end
end

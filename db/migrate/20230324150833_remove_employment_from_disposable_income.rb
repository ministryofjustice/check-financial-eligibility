class RemoveEmploymentFromDisposableIncome < ActiveRecord::Migration[7.0]
  def change
    change_table :disposable_income_summaries, bulk: true do |t|
      t.remove :employment_income_deductions,
               :fixed_employment_allowance,
               :tax,
               :national_insurance,
               type: :decimal, default: 0, null: false
    end
  end
end

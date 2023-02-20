class RemoveGrossIncomeSummaryFields < ActiveRecord::Migration[7.0]
  def change
    change_table :gross_income_summaries, bulk: true do |t|
      t.remove :upper_threshold,
               :monthly_state_benefits,
               :gross_employment_income,
               :benefits_in_kind,
               type: :decimal, default: 0, null: false

      t.remove :monthly_other_income,
               :monthly_unspecified_source,
               :combined_total_gross_income,
               :monthly_student_loan,
               type: :decimal

      t.remove :total_gross_income,
               :student_loan,
               :benefits_all_sources,
               :friends_or_family_all_sources,
               :maintenance_in_all_sources,
               :property_or_lodger_all_sources,
               :pension_all_sources,
               :benefits_bank,
               :friends_or_family_bank,
               :maintenance_in_bank,
               :property_or_lodger_bank,
               :pension_bank,
               :benefits_cash,
               :friends_or_family_cash,
               :maintenance_in_cash,
               :property_or_lodger_cash,
               :pension_cash,
               :unspecified_source,
               type: :decimal, default: 0

      t.remove :assessment_error, type: :boolean, default: false

      t.remove :assessment_result, type: :string, default: "pending", null: false
    end
  end
end

class AddMonthlyOherIncomeToGrossIncomeSummary < ActiveRecord::Migration[6.0]
  def change
    # rubocop:disable Rails/BulkChangeTable
    add_column :gross_income_summaries, :monthly_other_income, :decimal
    add_column :gross_income_summaries, :assessment_error, :boolean, default: false
    # rubocop:enable Rails/BulkChangeTable
  end
end

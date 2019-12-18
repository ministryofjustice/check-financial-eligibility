class AddAssessmentResultToGrossIncomeSummaries < ActiveRecord::Migration[6.0]
  def change
    add_column :gross_income_summaries, :assessment_result, :string, default: 'pending', null: false
  end
end

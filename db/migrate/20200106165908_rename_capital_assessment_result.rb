class RenameCapitalAssessmentResult < ActiveRecord::Migration[6.0]
  def change
    rename_column :capital_summaries, :capital_assessment_result, :assessment_result
  end
end

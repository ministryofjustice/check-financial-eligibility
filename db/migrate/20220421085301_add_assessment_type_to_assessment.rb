class AddAssessmentTypeToAssessment < ActiveRecord::Migration[7.0]
  def change
    add_column :assessments, :assessment_type, :string
  end
end

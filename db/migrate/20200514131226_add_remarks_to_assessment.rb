class AddRemarksToAssessment < ActiveRecord::Migration[6.0]
  def change
    add_column :assessments, :remarks, :text
  end
end

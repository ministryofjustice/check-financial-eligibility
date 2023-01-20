class AddLevelOfRepresentationToAssessments < ActiveRecord::Migration[7.0]
  def change
    add_column :assessments, :level_of_representation, :integer, default: 0
  end
end

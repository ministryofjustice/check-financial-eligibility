class DropProceedingAndMatterFromAssessments < ActiveRecord::Migration[7.0]
  def change
    remove_column :assessments, :matter_proceeding_type, :string
    remove_column :assessments, :proceeding_type_codes, :string
  end
end

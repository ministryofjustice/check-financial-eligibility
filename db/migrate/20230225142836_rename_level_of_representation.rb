class RenameLevelOfRepresentation < ActiveRecord::Migration[7.0]
  def change
    rename_column :assessments, :level_of_representation, :level_of_help
    change_column_null :assessments, :level_of_help, false
  end
end

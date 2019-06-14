class ModifyAssessment < ActiveRecord::Migration[5.2]
  def change
    add_column :assessments, :submission_date, :date, null: false
    add_column :assessments, :matter_proceeding_type, :string, null: false
    remove_column :assessments, :request_payload
    remove_column :assessments, :response_payload
    remove_column :assessments, :result
  end
end

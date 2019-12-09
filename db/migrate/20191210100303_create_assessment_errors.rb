class CreateAssessmentErrors < ActiveRecord::Migration[6.0]
  def change
    create_table :assessment_errors do |t|
      t.belongs_to :assessment, foreign_key: true, null: false, type: :uuid
      t.uuid :record_id
      t.string :record_type
      t.string :error_message
    end
  end
end

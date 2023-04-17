class DropAssessmentErrors < ActiveRecord::Migration[7.0]
    def change
      drop_table :assessment_errors
    end
  end
  
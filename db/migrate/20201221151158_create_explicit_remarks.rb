class CreateExplicitRemarks < ActiveRecord::Migration[6.0]
  def change
    create_table :explicit_remarks do |t|
      t.uuid :assessment_id
      t.string :category
      t.string :remark

      t.timestamps
    end
  end
end

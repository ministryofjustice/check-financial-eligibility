class CreateDependents < ActiveRecord::Migration[5.2]
  def change
    create_table :dependents, id: :uuid do |t|
      t.uuid :assessment_id
      t.date :date_of_birth
      t.boolean :in_full_time_education

      t.timestamps
    end
  end
end

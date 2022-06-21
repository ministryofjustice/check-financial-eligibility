class CreateCrimeEligibilities < ActiveRecord::Migration[7.0]
  def change
    create_table :crime_eligibilities, id: :uuid do |t|
      t.uuid :parent_id, null: false
      t.string :type
      t.decimal :lower_threshold
      t.decimal :upper_threshold
      t.string :assessment_result, null: false, default: "pending"

      t.timestamps
    end
  end
end

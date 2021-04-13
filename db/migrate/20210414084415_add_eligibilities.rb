class AddEligibilities < ActiveRecord::Migration[6.1]
  def change
    create_table :eligibilities, id: :uuid do |t|
      t.uuid :parent_id, null: false
      t.string :type
      t.string :proceeding_type_code, null: false
      t.decimal :lower_threshold
      t.decimal :upper_threshold
      t.string :assessment_result, null: false, default: 'pending'

      t.timestamps
    end

    add_index :eligibilities, %i[parent_id proceeding_type_code], unique: true
  end
end

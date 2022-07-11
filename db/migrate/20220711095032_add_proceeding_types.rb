class AddProceedingTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :proceeding_types, id: :uuid do |t|
      t.references :assessment, foreign_key: true, type: :uuid
      t.string :ccms_code, null: false
      t.string :client_involvement_type, null: false
      t.timestamps
    end
  end
end

class AddOtherIncomeSources < ActiveRecord::Migration[6.0]
  def change
    create_table :other_income_sources, id: :uuid do |t|
      t.belongs_to :gross_income_summary, foreign_key: true, null: false, type: :uuid
      t.string :name, null: false

      t.timestamps
    end
  end
end

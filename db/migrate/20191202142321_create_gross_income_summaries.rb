class CreateGrossIncomeSummaries < ActiveRecord::Migration[6.0]
  def change
    create_table :gross_income_summaries, id: :uuid do |t|
      t.references :assessment, foreign_key: true, type: :uuid
      t.timestamps
    end
  end
end

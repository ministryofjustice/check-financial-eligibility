class RemoveMoreColumnsFromCapitalSummaries < ActiveRecord::Migration[7.0]
  def change
    change_table :capital_summaries, bulk: true do |t|
      t.remove(:total_property,
               :upper_threshold,
               :lower_threshold,
               :pensioner_capital_disregard,
               :subject_matter_of_dispute_disregard,
               type: :decimal, null: false, default: 0)
      t.remove(:combined_assessed_capital,
               type: :decimal, null: true, default: nil)
    end
  end
end

class Ap885CreateCapitalSummaries < ActiveRecord::Migration[5.2]
  def change
    create_table :capital_summaries, id: :uuid do |t|
      t.references :assessment, foreign_key: true, type: :uuid
      t.decimal :total_liquid, default: 0.0, null: false
      t.decimal :total_non_liquid, default: 0.0, null: false
      t.decimal :total_vehicle, default: 0.0, null: false
      t.decimal :total_property, default: 0.0, null: false
      t.decimal :total_mortgage_allowance, default: 0.0, null: false
      t.decimal :total_capital, default: 0.0, null: false
      t.decimal :pensioner_capital_disregard, default: 0.0, null: false
      t.decimal :assessed_capital, default: 0.0, null: false
      t.decimal :capital_contribution, default: 0.0, null: false
      t.decimal :lower_threshold, default: 0.0, null: false
      t.decimal :upper_threshold, default: 0.0, null: false
      t.string :capital_assessment_result, default: 'pending', null: false

      t.timestamps
    end
  end
end

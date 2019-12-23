class CreateDisposableIncomeSummary < ActiveRecord::Migration[6.0]
  def change
    create_table :disposable_income_summary, id: :uuid do |t|
      t.belongs_to :assessment, foreign_key: true, null: false, type: :uuid
      t.decimal :monthly_childcare, default: 0.0, null: false
      t.decimal :monthly_dependant_allowance, default: 0.0, null: false
      t.decimal :monthly_maintenance, default: 0.0, null: false
      t.decimal :monthly_housing_costs, default: 0.0, null: false
      t.decimal :total_monthly_outgoings, default: 0.0, null: false
      t.decimal :total_disposable_income, default: 0.0, null: false
      t.decimal :lower_threshold, default: 0.0, null: false
      t.decimal :upper_threshold, default: 0.0, null: false
      t.string :assessment_result, default: 'pending', null: false
      t.string :housing_cost_type, null: false
      t.timestamps
    end
  end
end

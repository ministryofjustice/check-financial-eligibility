class Ap885AddColumns < ActiveRecord::Migration[5.2]
  def up
    # rubocop:disable Rails/BulkChangeTable
    add_column :assessments, :assessment_result, :string, null: false, default: 'pending'

    remove_column :properties, :assessment_id
    add_reference :properties, :capital_summary, foreign_key: true, type: :uuid
    add_column :properties, :transaction_allowance, :decimal, null: false, default: 0.0
    add_column :properties, :allowable_outstanding_mortgage, :decimal, null: false, default: 0.0
    add_column :properties, :net_value, :decimal, null: false, default: 0.0
    add_column :properties, :net_equity, :decimal, null: false, default: 0.0
    add_column :properties, :assessed_equity, :decimal, null: false, default: 0.0
    add_column :properties, :main_home_equity_disregard, :decimal, null: false, default: 0.0

    remove_column :vehicles, :assessment_id
    add_reference :vehicles, :capital_summary, foreign_key: true, type: :uuid
    add_column :vehicles, :included_in_assessment, :boolean, null: false, default: false
    add_column :vehicles, :assessed_value, :decimal, null: false, default: 0.0
    # rubocop:enable Rails/BulkChangeTable
  end

  def down
    # rubocop:disable Rails/BulkChangeTable
    remove_column :assessments, :assessment_result

    add_reference :properties, :assessment, foreign_key: true, type: :uuid
    remove_column :properties, :capital_summary_id
    remove_column :properties, :transaction_allowance
    remove_column :properties, :allowable_outstanding_mortgage
    remove_column :properties, :net_value
    remove_column :properties, :net_equity
    remove_column :properties, :main_home_equity_disregard
    remove_column :properties, :assessed_equity

    add_reference :vehicles, :assessment, foreign_key: true, type: :uuid
    remove_column :vehicles, :capital_summary_id
    remove_column :vehicles, :included_in_assessment
    remove_column :vehicles, :assessed_value
    # rubocop:enable Rails/BulkChangeTable
  end
end

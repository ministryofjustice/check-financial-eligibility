# rubocop:disable Rails/BulkChangeTable
class RemoveUnusedCols < ActiveRecord::Migration[7.0]
  def change
    remove_column :gross_income_summaries, :friends_or_family, :decimal, default: 0.0
    remove_column :gross_income_summaries, :maintenance_in, :decimal, default: 0.0
    remove_column :gross_income_summaries, :property_or_lodger, :decimal, default: 0.0
    remove_column :gross_income_summaries, :pension, :decimal, default: 0.0
    remove_column :disposable_income_summaries, :childcare, :decimal, default: 0.0
    remove_column :disposable_income_summaries, :maintenance, :decimal, default: 0.0
    remove_column :disposable_income_summaries, :legal_aid, :decimal, default: 0.0
  end
end
# rubocop:enable Rails/BulkChangeTable

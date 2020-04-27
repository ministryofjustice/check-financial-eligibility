class AddLegalAidToDisposableIncomeSummary < ActiveRecord::Migration[6.0]
  def change
    add_column :disposable_income_summaries, :legal_aid, :decimal, default: 0.0, null: false
  end
end

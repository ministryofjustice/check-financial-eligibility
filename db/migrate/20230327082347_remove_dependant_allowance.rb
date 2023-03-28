class RemoveDependantAllowance < ActiveRecord::Migration[7.0]
  def change
    change_table :disposable_income_summaries, bulk: true do |t|
      t.remove :dependant_allowance,
               type: :decimal, default: 0, null: false
    end
  end
end

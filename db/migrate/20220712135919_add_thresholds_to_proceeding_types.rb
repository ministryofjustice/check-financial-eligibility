class AddThresholdsToProceedingTypes < ActiveRecord::Migration[7.0]
  def change
    change_table :proceeding_types, bulk: true do |t|
      t.decimal :gross_income_upper_threshold
      t.decimal :disposable_income_upper_threshold
      t.decimal :capital_upper_threshold
    end
  end
end

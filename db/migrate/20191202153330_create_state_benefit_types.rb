class CreateStateBenefitTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :state_benefit_types, id: :uuid do |t|
      t.string :label
      t.text :description
      t.boolean :exclude_from_gross_income

      t.timestamps
    end
  end
end

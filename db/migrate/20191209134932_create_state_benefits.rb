class CreateStateBenefits < ActiveRecord::Migration[6.0]
  def change
    create_table :state_benefits, id: :uuid do |t|
      t.belongs_to :gross_income_summary, foreign_key: true, null: false, type: :uuid
      t.belongs_to :state_benefit_type, foreign_key: true, null: false, type: :uuid
      t.string :name
      t.timestamps
    end
  end
end

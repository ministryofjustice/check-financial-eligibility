class CreateEmployments < ActiveRecord::Migration[6.0]
  def change
    create_table :employments, id: :uuid do |t|
      t.references :gross_income_summary, foreign_key: true, type: :uuid
      t.string :name, null: false
      t.decimal :monthly_income
      t.timestamps
    end
  end
end

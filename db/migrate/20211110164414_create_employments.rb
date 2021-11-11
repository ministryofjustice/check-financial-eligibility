class CreateEmployments < ActiveRecord::Migration[6.1]
  def change
    create_table :employments, id: :uuid do |t|
      t.references :assessment, foreign_key: true, type: :uuid
      t.string :name
      t.decimal :monthly_employment_income, null: false, default: 0.0
      t.decimal :monthly_employment_deductions, null: false, default: 0.0

      t.timestamps
    end
  end
end

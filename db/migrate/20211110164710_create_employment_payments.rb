class CreateEmploymentPayments < ActiveRecord::Migration[6.1]
  def change
    create_table :employment_payments, id: :uuid do |t|
      t.references :employment, foreign_key: true, type: :uuid
      t.date :date, null: false
      t.decimal :gross_income, null: false, default: 0.0
      t.decimal :benefits_in_kind, null: false, default: 0.0
      t.decimal :tax, null: false, default: 0.0
      t.decimal :national_insurance, null: false, default: 0.0

      t.timestamps
    end
  end
end

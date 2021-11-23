class UpdateFieldsOnEmployment < ActiveRecord::Migration[6.1]
  def change
    remove_column :employments, :monthly_employment_income, :decimal, null: false, default: 0.0
    remove_column :employments, :monthly_employment_deductions, :decimal, null: false, default: 0.0
    add_column :employments, :monthly_gross_income, :decimal, null: false, default: 0.0
    add_column :employments, :monthly_benefits_in_kind, :decimal, null: false, default: 0.0
    add_column :employments, :monthly_tax, :decimal, null: false, default: 0.0
    add_column :employments, :monthly_national_insurance, :decimal, null: false, default: 0.0
  end
end

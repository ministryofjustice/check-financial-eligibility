class AddCategoryToStateBenefitTypes < ActiveRecord::Migration[6.0]
  def change
    add_column :state_benefit_types, :category, :string
  end
end

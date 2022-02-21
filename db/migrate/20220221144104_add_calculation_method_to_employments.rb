class AddCalculationMethodToEmployments < ActiveRecord::Migration[6.1]
  def change
    add_column :employments, :calculation_method, :string
  end
end

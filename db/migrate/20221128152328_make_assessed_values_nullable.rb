class MakeAssessedValuesNullable < ActiveRecord::Migration[7.0]
  def up
    change_column :properties, :assessed_equity, :decimal, null: true, default: nil
    change_column :vehicles, :assessed_value, :decimal, null: true, default: nil
  end

  def down
    change_column :properties, :assessed_equity, :decimal, null: false, default: 0
    change_column :vehicles, :assessed_value, :decimal, null: false, default: 0
  end
end

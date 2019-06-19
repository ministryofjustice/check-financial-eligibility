class CreateProperties < ActiveRecord::Migration[5.2]
  def change
    create_table :properties, id: :uuid do |t|
      t.belongs_to :assessment, foreign_key: true, null: false, type: :uuid
      t.decimal :value
      t.decimal :outstanding_mortgage
      t.decimal :percentage_owned
      t.boolean :main_home
      t.boolean :shared_with_housing_assoc

      t.timestamps
    end
  end
end

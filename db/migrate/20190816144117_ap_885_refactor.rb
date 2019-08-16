class Ap885Refactor < ActiveRecord::Migration[5.2]
  def change
    create_table :capital_items, id: :uuid do |t|
      t.references :capital_summary, foreign_key: true, type: :uuid
      t.string :type, null: false
      t.string :description, null: false
      t.decimal :value, default: 0.0, null: false
      t.timestamps
    end
  end
end

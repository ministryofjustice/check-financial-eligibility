class CreateNonLiquidAssets < ActiveRecord::Migration[5.2]
  def change
    create_table :non_liquid_assets, id: :uuid do |t|
      t.belongs_to :assessment, foreign_key: true, null: false, type: :uuid
      t.string :description
      t.decimal :value

      t.timestamps
    end
  end
end

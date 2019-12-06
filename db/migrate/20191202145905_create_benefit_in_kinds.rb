class CreateBenefitInKinds < ActiveRecord::Migration[6.0]
  def change
    create_table :benefit_in_kinds, id: :uuid do |t|
      t.references :employment, foreign_key: true, type: :uuid
      t.string :description, null: false
      t.decimal :value, null: false
      t.timestamps
    end
  end
end

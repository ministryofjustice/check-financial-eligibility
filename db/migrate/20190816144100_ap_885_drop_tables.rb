class Ap885DropTables < ActiveRecord::Migration[5.2]
  def up
    drop_table :bank_accounts
    drop_table :non_liquid_assets
    drop_table :results
  end

  def down
    create_table :bank_accounts, id: :uuid do |t|
      t.belongs_to :assessment, foreign_key: true, null: false, type: :uuid
      t.string :name
      t.decimal :lowest_balance
      t.timestamps
    end

    create_table :non_liquid_assets, id: :uuid do |t|
      t.belongs_to :assessment, foreign_key: true, null: false, type: :uuid
      t.string :description
      t.decimal :value
      t.timestamps
    end

    create_table :results do |t|
      t.uuid :assessment_id
      t.string :state
      t.jsonb :details
      t.timestamps
    end
  end
end

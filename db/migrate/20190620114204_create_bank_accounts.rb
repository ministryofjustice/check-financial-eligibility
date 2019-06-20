class CreateBankAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :bank_accounts, id: :uuid do |t|
      t.belongs_to :assessment, foreign_key: true, null: false, type: :uuid
      t.string :name
      t.decimal :lowest_balance

      t.timestamps
    end
  end
end

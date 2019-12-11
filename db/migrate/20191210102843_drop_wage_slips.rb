class DropWageSlips < ActiveRecord::Migration[6.0]
  def up
    drop_table :wage_slips
  end

  def down
    create_table 'wage_slips', force: :cascade do |t|
      t.uuid 'assessment_id', null: false
      t.date 'payment_date'
      t.decimal 'gross_pay'
      t.decimal 'paye'
      t.decimal 'nic'
      t.datetime 'created_at', null: false
      t.datetime 'updated_at', null: false
      t.index ['assessment_id'], name: 'index_wage_slips_on_assessment_id'
    end
  end
end

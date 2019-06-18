class CreateApplicants < ActiveRecord::Migration[5.2]
  def change
    create_table :applicants, id: :uuid do |t|
      t.belongs_to :assessment, foreign_key: true, null: false, type: :uuid
      t.date :date_of_birth
      t.string :involvement_type
      t.boolean :has_partner_opponent
      t.boolean :receives_qualifying_benefit

      t.timestamps
    end
  end
end

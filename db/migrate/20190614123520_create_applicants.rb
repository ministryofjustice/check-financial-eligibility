class CreateApplicants < ActiveRecord::Migration[5.2]
  def change
    create_table :applicants do |t|
      t.uuid :assessment_id
      t.datetime :date_of_birth
      t.string :involvement_type
      t.boolean :has_partner_opponent
      t.boolean :receives_qualifying_benefit

      t.timestamps
    end
  end
end

class AddSelfEmployedToApplicants < ActiveRecord::Migration[6.0]
  def change
    add_column :applicants, :self_employed, :boolean, default: false
  end
end

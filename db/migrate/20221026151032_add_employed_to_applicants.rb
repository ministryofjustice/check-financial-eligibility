class AddEmployedToApplicants < ActiveRecord::Migration[7.0]
  def change
    add_column :applicants, :employed, :boolean, null: true
  end
end

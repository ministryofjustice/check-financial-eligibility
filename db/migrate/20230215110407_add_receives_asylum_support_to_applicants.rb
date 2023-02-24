class AddReceivesAsylumSupportToApplicants < ActiveRecord::Migration[7.0]
  def change
    add_column :applicants, :receives_asylum_support, :boolean, default: false
  end
end

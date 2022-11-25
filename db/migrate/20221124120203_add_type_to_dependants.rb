class AddTypeToDependants < ActiveRecord::Migration[7.0]
  def change
    add_column :dependants, :type, :string, default: "ApplicantDependant"
  end
end

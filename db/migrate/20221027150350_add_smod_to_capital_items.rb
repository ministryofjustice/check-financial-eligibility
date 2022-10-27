class AddSmodToCapitalItems < ActiveRecord::Migration[7.0]
  def change
    add_column :capital_items, :subject_matter_of_dispute, :boolean, default: false
    add_column :vehicles, :subject_matter_of_dispute, :boolean, default: false
    add_column :properties, :subject_matter_of_dispute, :boolean, default: false
    add_column :capital_summaries, :subject_matter_of_dispute_disregard, :decimal, default: "0.0", null: false
  end
end

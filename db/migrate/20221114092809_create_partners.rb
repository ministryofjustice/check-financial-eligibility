class CreatePartners < ActiveRecord::Migration[7.0]
  def change
    create_table :partners do |t|
      t.references :assessment, null: false, foreign_key: true, type: :uuid
      t.date :date_of_birth
      t.boolean :employed

      t.timestamps
    end

    add_column :capital_summaries, :type, :string, default: "ApplicantCapitalSummary"
    add_column :gross_income_summaries, :type, :string, default: "ApplicantGrossIncomeSummary"
    add_column :disposable_income_summaries, :type, :string, default: "ApplicantDisposableIncomeSummary"
    add_column :employments, :type, :string, default: "ApplicantEmployment"
  end
end

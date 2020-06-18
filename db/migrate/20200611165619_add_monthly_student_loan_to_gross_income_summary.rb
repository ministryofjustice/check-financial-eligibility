class AddMonthlyStudentLoanToGrossIncomeSummary < ActiveRecord::Migration[6.0]
  def change
    add_column :gross_income_summaries, :monthly_student_loan, :decimal
  end
end

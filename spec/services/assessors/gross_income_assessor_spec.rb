require 'rails_helper'

module Assessors
  RSpec.describe GrossIncomeAssessor do
    let(:assessment) { create :assessment, :with_gross_income_summary }
    let(:gross_income_summary) { assessment.gross_income_summary }

    describe '.call' do
      subject { described_class.call(assessment) }

      context 'gross income has been summarised' do
        context 'monthly income below upper threshold' do
          it 'is eligible' do
            set_gross_income_values gross_income_summary, 1_023, 0.0, 45.3, 2_567
            subject
            expect(gross_income_summary.summarized_assessment_result).to eq :eligible
          end
        end

        context 'monthly income equals upper threshold' do
          it 'is not eligible' do
            set_gross_income_values gross_income_summary, 2_000, 0.0, 567.00, 2_567.00
            subject
            expect(gross_income_summary.summarized_assessment_result).to eq :ineligible
          end
        end

        context 'monthly income above upper threshold' do
          it 'is not eligible' do
            set_gross_income_values gross_income_summary, 2_100.0, 0.0, 500.2, 2_567
            subject
            expect(gross_income_summary.summarized_assessment_result).to eq :ineligible
          end
        end

        def set_gross_income_values(record, other_income, monthly_student_loan, state_benefits, threshold)
          record.update!(monthly_other_income: other_income,
                         monthly_student_loan:,
                         monthly_state_benefits: state_benefits,
                         total_gross_income: other_income + state_benefits + monthly_student_loan,
                         upper_threshold: threshold,
                         assessment_result: 'summarised')
          create :gross_income_eligibility, gross_income_summary: record, upper_threshold: threshold
        end
      end
    end
  end
end

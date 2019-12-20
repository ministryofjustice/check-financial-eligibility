require 'rails_helper'

module Assessors
  RSpec.describe GrossIncomeAssessor do
    let(:assessment) { create :assessment }
    let(:gross_income_summary) { assessment.gross_income_summary }

    describe '.call' do
      subject { described_class.call(assessment) }

      context 'gross_income has not been summarised' do
        it 'raises' do
          allow(gross_income_summary).to receive(:assessment_result).and_return('pending')
          expect { subject }.to raise_error RuntimeError, 'Gross income not summarised'
        end
      end

      context 'gross income is not available' do
        it 'raises' do
          allow(gross_income_summary).to receive(:assessment_result).and_return('not_applicable')
          expect { subject }.to raise_error RuntimeError, 'Gross income summary marked as not applicable'
        end
      end

      context 'gross income has been summarised' do
        context 'monthly income below upper threshold' do
          it 'is eligible' do
            set_gross_income_values gross_income_summary, 1_023, 45.3, 2_567
            subject
            expect(gross_income_summary.assessment_result).to eq 'eligible'
          end
        end

        context 'monthly income equals upper threshold' do
          it 'is not eligible' do
            set_gross_income_values gross_income_summary, 2_000, 567, 2_567
            subject
            expect(gross_income_summary.assessment_result).to eq 'not_eligible'
          end
        end

        context 'monthly income above upper threshold' do
          it 'is not eligible' do
            set_gross_income_values gross_income_summary, 2_100.0, 500.2, 2_567
            subject
            expect(gross_income_summary.assessment_result).to eq 'not_eligible'
          end
        end

        def set_gross_income_values(record, other_income, state_benefits, threshold)
          record.update!(monthly_other_income: other_income,
                         monthly_state_benefits: state_benefits,
                         upper_threshold: threshold,
                         assessment_result: 'summarised')
        end
      end
    end
  end
end

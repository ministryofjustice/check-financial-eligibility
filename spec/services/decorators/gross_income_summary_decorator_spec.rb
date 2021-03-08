require 'rails_helper'

module Decorators
  RSpec.describe GrossIncomeSummaryDecorator do
    describe '#as_json' do
      subject { described_class.new(gross_income_summary).as_json }

      context 'record is nil' do
        let(:gross_income_summary) { nil }
        it 'returns nil' do
          expect(subject).to be_nil
        end
      end

      context 'record exists' do
        before { create :disposable_income_summary, :with_everything, assessment: gross_income_summary.assessment }

        context 'student loan payments are in irregular income' do
          let!(:gross_income_summary) { create :gross_income_summary, :with_all_records }

          it 'returns a hash with the expected keys' do
            expected_keys = %i[summary
                               irregular_income
                               state_benefits
                               other_income]
            expect(subject.keys).to eq expected_keys
          end

          it 'returns expected keys for summary' do
            expected_keys = %i[total_gross_income
                               upper_threshold
                               assessment_result]
            expect(subject[:summary].keys).to match expected_keys
          end

          it 'returns expected keys for monthly income equivalents' do
            expected_keys = %i[friends_or_family
                               maintenance_in
                               property_or_lodger
                               pension]
            expect(subject[:other_income][:monthly_equivalents][:all_sources].keys).to match expected_keys
          end

          it 'returns expected keys for state benefits' do
            expected_keys = %i[all_sources
                               cash_transactions
                               bank_transactions]
            expect(subject[:state_benefits][:monthly_equivalents].keys).to match expected_keys
          end

          it 'returns expected keys for student_loan' do
            expected_keys = %i[student_loan]
            expect(subject[:irregular_income][:monthly_equivalents].keys).to match expected_keys
          end

          it 'calls StateBenefitDecorator for each state benefit' do
            expected_count = gross_income_summary.state_benefits.count
            expect(StateBenefitDecorator).to receive(:new).and_return(double('oisd', as_json: nil)).exactly(expected_count).times
            subject
          end

          it 'calls the OtherIncomeSourceDecorator once' do
            expect(OtherIncomeSourceDecorator).to receive(:new).and_return(double('sbd', as_json: nil)).exactly(1).times
            subject
          end
        end
      end
    end
  end
end

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
          let!(:gross_income_summary) { create :gross_income_summary, :with_irregular_income_payments }

          it 'returns a hash with the expected keys' do
            expected_keys = %i[monthly_student_loan
                               monthly_other_income
                               monthly_state_benefits
                               total_gross_income
                               upper_threshold
                               assessment_result
                               monthly_income_equivalents
                               monthly_outgoing_equivalents
                               state_benefits
                               other_income
                               irregular_income]
            expect(subject.keys).to eq expected_keys
          end

          it 'returns expected keys for monthly_income_equivalents' do
            expected_keys = %i[friends_or_family
                               maintenance_in
                               property_or_lodger
                               pension]
            expect(subject[:monthly_income_equivalents].keys).to match expected_keys
          end

          it 'calls StateBenefitDecorator for each state benefit' do
            expected_count = gross_income_summary.state_benefits.count
            expect(StateBenefitDecorator).to receive(:new).and_return(double('oisd', as_json: nil)).exactly(expected_count).times
            subject
          end
          it 'calls the OtherIncomeSourceDecorator for each other income source' do
            expected_count = gross_income_summary.other_income_sources.count
            expect(OtherIncomeSourceDecorator).to receive(:new).and_return(double('sbd', as_json: nil)).exactly(expected_count).times
            subject
          end
          it 'calls the IrregularIncomePaymentsDecorator for irregular_income' do
            expect(IrregularIncomePaymentsDecorator).to receive(:new).and_return(double('sbd', as_json: nil))
            subject
          end
        end
      end

      context 'version 3 record exists' do
        before { create :disposable_income_summary, :with_everything, assessment: gross_income_summary.assessment }

        context 'student loan payments are in irregular income' do
          let!(:gross_income_summary) { create :gross_income_summary, :with_irregular_income_payments, :with_latest_version }

          it 'returns a hash with the expected keys' do
            expected_keys = %i[summary
                               student_loan
                               other_income]
            expect(subject.keys).to eq expected_keys
          end

          it 'returns expected keys for summary' do
            expected_keys = %i[total_gross_income
                               upper_threshold
                               assessment_result]
            expect(subject[:summary].keys).to match expected_keys
          end

          it 'returns expected keys for student_loan' do
            expected_keys = %i[monthly_equivalents]
            expect(subject[:student_loan].keys).to match expected_keys
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

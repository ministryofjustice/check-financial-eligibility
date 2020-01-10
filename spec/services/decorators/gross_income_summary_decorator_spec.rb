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
        let(:gross_income_summary) { create :gross_income_summary, :with_everything }

        it 'returns a hash with the expected keys' do
          expected_keys = %i[monthly_other_income
                             monthly_state_benefits
                             total_gross_income
                             upper_threshold
                             assessment_result
                             state_benefits
                             other_income]
          expect(subject.keys).to eq expected_keys
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
      end
    end
  end
end

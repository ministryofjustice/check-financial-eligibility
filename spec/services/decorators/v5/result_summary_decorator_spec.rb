require 'rails_helper'

module Decorators
  module V5
    RSpec.describe ResultSummaryDecorator do
      before { mock_lfa_responses }
      let(:assessment) do
        create :assessment,
               :with_gross_income_summary,
               :with_disposable_income_summary,
               :with_capital_summary,
               :with_applicant,
               :with_eligibilities
      end

      describe '#as_json' do
        subject { ResultSummaryDecorator.new(assessment).as_json }

        it 'has the required keys in the returned hash' do
          expected_keys = %i[
            result
            capital_contribution
            income_contribution
            matter_types
            proceeding_types
          ]
          expect(subject.keys).to eq %i[overall_result gross_income disposable_income capital]
          expect(subject[:overall_result].keys).to eq expected_keys
        end

        it 'calls the decorators for associated records' do
          expect(::Decorators::V4::CapitalResultDecorator).to receive(:new).and_return(double('cr', as_json: nil))
          expect(::Decorators::V4::GrossIncomeResultDecorator).to receive(:new).and_return(double('gir', as_json: nil))
          expect(::Decorators::V4::MatterTypeResultDecorator).to receive(:new).and_return(double('mtr', as_json: nil))
          expect(::Decorators::V4::ProceedingTypesResultDecorator).to receive(:new).and_return(double('ptr', as_json: nil))
          expect(DisposableIncomeResultDecorator).to receive(:new).and_return(double('dir', as_json: nil))
          subject
        end
      end
    end
  end
end

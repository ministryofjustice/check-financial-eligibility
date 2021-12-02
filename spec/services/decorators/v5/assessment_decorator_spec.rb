require 'rails_helper'

module Decorators
  module V5
    RSpec.describe AssessmentDecorator do
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
        subject { AssessmentDecorator.new(assessment).as_json }

        it 'has the required keys in the returned hash' do
          expected_keys = %i[
            id
            client_reference_id
            submission_date
            applicant
            gross_income
            disposable_income
            capital
            remarks
          ]
          expect(subject.keys).to eq %i[version timestamp success result_summary assessment]
          expect(subject[:assessment].keys).to eq expected_keys
        end

        it 'calls the decorators for associated records' do
          expect(::Decorators::V3::ApplicantDecorator).to receive(:new).and_return(double('ad', as_json: nil))
          expect(GrossIncomeDecorator).to receive(:new).and_return(double('gisd', as_json: nil))
          expect(::Decorators::V4::DisposableIncomeDecorator).to receive(:new).and_return(double('disd', as_json: nil))
          expect(::Decorators::V4::CapitalDecorator).to receive(:new).and_return(double('csd', as_json: nil))
          expect(::Decorators::V3::RemarksDecorator).to receive(:new).and_return(double('rmk', as_json: nil))
          expect(ResultSummaryDecorator).to receive(:new).and_return(double('res', as_json: nil))
          subject
        end
      end
    end
  end
end

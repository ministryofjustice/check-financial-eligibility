require 'rails_helper'

module Decorators
  RSpec.describe AssessmentDecorator do
    let(:assessment) do
      create :assessment,
             :with_gross_income_summary,
             :with_disposable_income_summary,
             :with_capital_summary,
             :with_applicant
    end

    describe '#as_json' do
      subject { AssessmentDecorator.new(assessment).as_json }

      it 'has the required keys in the returned hash' do
        expected_keys = %i[
          id
          client_reference_id
          submission_date
          matter_proceeding_type
          assessment_result
          applicant
          gross_income
          disposable_income
          capital
          remarks
        ]
        expect(subject.keys).to eq %i[version timestamp success assessment]
        expect(subject[:assessment].keys).to eq expected_keys
      end

      it 'calls the decorators for associated records' do
        expect(ApplicantDecorator).to receive(:new).and_return(double('ad', as_json: nil))
        expect(GrossIncomeSummaryDecorator).to receive(:new).and_return(double('gisd', as_json: nil))
        expect(DisposableIncomeSummaryDecorator).to receive(:new).and_return(double('disd', as_json: nil))
        expect(CapitalSummaryDecorator).to receive(:new).and_return(double('csd', as_json: nil))
        subject
      end

      it 'calls #as_json on the remarks object' do
        expect_any_instance_of(Remarks).to receive(:as_json)
        subject
      end
    end
  end
end

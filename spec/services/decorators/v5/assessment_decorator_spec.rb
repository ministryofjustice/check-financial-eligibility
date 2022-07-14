require "rails_helper"

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

      describe "#as_json" do
        subject(:decorator) { described_class.new(assessment).as_json }

        it "has the required keys in the returned hash" do
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
          expect(decorator.keys).to eq %i[version timestamp success result_summary assessment]
          expect(decorator[:assessment].keys).to eq expected_keys
        end

        it "calls the decorators for associated records" do
          allow(::Decorators::V3::ApplicantDecorator).to receive(:new).and_return(instance_double("ad", as_json: nil))
          allow(::Decorators::V4::GrossIncomeDecorator).to receive(:new).and_return(instance_double("gisd", as_json: nil))
          allow(::Decorators::V4::DisposableIncomeDecorator).to receive(:new).and_return(instance_double("disd", as_json: nil))
          allow(::Decorators::V4::CapitalDecorator).to receive(:new).and_return(instance_double("csd", as_json: nil))
          allow(::Decorators::V3::RemarksDecorator).to receive(:new).and_return(instance_double("rmk", as_json: nil))
          allow(::Decorators::V4::ResultSummaryDecorator).to receive(:new).and_return(instance_double("rsd", as_json: nil))
          decorator
        end
      end
    end
  end
end

require "rails_helper"

module Decorators
  module V3
    RSpec.describe AssessmentDecorator do
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
            matter_proceeding_type
            assessment_result
            applicant
            gross_income
            disposable_income
            capital
            remarks
          ]
          expect(decorator.keys).to eq %i[version timestamp success assessment]
          expect(decorator[:assessment].keys).to eq expected_keys
        end

        it "calls the decorators for associated records" do
          allow(ApplicantDecorator).to receive(:new).and_return(instance_double("ad", as_json: nil))
          allow(GrossIncomeSummaryDecorator).to receive(:new).and_return(instance_double("gisd", as_json: nil))
          allow(DisposableIncomeSummaryDecorator).to receive(:new).and_return(instance_double("disd", as_json: nil))
          allow(CapitalSummaryDecorator).to receive(:new).and_return(instance_double("csd", as_json: nil))
          allow(RemarksDecorator).to receive(:new).and_return(instance_double("rmk", as_json: nil))
          decorator
        end
      end
    end
  end
end

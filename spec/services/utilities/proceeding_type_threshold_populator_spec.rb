require "rails_helper"

module Utilities
  RSpec.describe ProceedingTypeThresholdPopulator do
    describe ".call" do
      let(:proceeding_hash) { [%w[DA001 A], %w[DA005 Z], %w[SE014 A]] }
      let(:assessment) { create :assessment, submission_date: Date.new(2022, 7, 12), proceedings: proceeding_hash }
      let(:response) do
        {
          request_id: "ba7de3c7-cfbe-43de-89b6-8afa2fbe4193",
          success: true,
          proceedings: [
            {
              ccms_code: "DA001",
              client_involvement_type: "A",
              gross_income_upper: true,
              disposable_income_upper: true,
              capital_upper: true,
              matter_type: "Domestic abuse",
            },
            {
              ccms_code: "DA005",
              client_involvement_type: "Z",
              gross_income_upper: false,
              disposable_income_upper: false,
              capital_upper: false,
              matter_type: "Domestic abuse",
            },
            {
              ccms_code: "SE014",
              client_involvement_type: "A",
              gross_income_upper: false,
              disposable_income_upper: false,
              capital_upper: false,
              matter_type: "Children - section 8",
            },
          ],
        }
      end
      let(:expected_payload) do
        [
          {
            ccms_code: "DA001",
            client_involvement_type: "A",
          },
          {
            ccms_code: "DA005",
            client_involvement_type: "Z",
          },
          {
            ccms_code: "SE014",
            client_involvement_type: "A",
          },
        ]
      end

      it "calls LegalFrameworkAPI::ThresholdWaivers with expected payload" do
        expect(LegalFrameworkAPI::MockThresholdWaivers).to receive(:call).with(expected_payload)
        allow(LegalFrameworkAPI::MockThresholdWaivers).to receive(:call).and_return(response)

        described_class.call(assessment)
      end

      it "updates the threshold values on the proceeding type records where the threshold is not waived" do
        allow(LegalFrameworkAPI::ThresholdWaivers).to receive(:call).and_return(response)

        described_class.call(assessment)

        pt = assessment.reload.proceeding_types.find_by(ccms_code: "DA005")
        expect(pt.gross_income_upper_threshold).to eq 2657.0
        expect(pt.disposable_income_upper_threshold).to eq 733.0
        expect(pt.capital_upper_threshold).to eq 8000.0

        pt = assessment.proceeding_types.find_by(ccms_code: "SE014")
        expect(pt.gross_income_upper_threshold).to eq 2657.0
        expect(pt.disposable_income_upper_threshold).to eq 733.0
        expect(pt.capital_upper_threshold).to eq 8000.0
      end

      it "updates threshold values on proceeding type records where the threshold is waived" do
        allow(LegalFrameworkAPI::ThresholdWaivers).to receive(:call).and_return(response)

        described_class.call(assessment)

        pt = assessment.reload.proceeding_types.find_by(ccms_code: "DA001")
        expect(pt.gross_income_upper_threshold).to eq 999_999_999_999.0
        expect(pt.disposable_income_upper_threshold).to eq 999_999_999_999.0
        expect(pt.capital_upper_threshold).to eq 999_999_999_999.0
      end
    end
  end
end

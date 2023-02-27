require "rails_helper"

module LegalFrameworkAPI
  RSpec.describe MockThresholdWaivers do
    before do
      allow(SecureRandom).to receive(:uuid).and_return("52fb18ad-257e-4ab1-91da-d7d5e4ff1068")
    end

    let(:proceeding_details) do
      [
        {
          ccms_code: "DA004",
          client_involvement_type: "A",
        },
        {
          ccms_code: "SE013",
          client_involvement_type: "D",
        },
        {
          ccms_code: "SE014",
          client_involvement_type: "I",
        },
        {
          ccms_code: "DA003",
          client_involvement_type: "W",
        },
        {
          ccms_code: "SE003",
          client_involvement_type: "Z",
        },
      ]
    end

    describe ".call" do
      subject(:service) { described_class.call(proceeding_details) }

      it "returns expected response" do
        expect(service).to eq expected_response
      end

      context "when given an unrecognised proceeding type" do
        let(:proceeding_details) do
          [
            {
              ccms_code: "IM039",
              client_involvement_type: "A",
            },
          ]
        end

        it "raises an error" do
          expect { service }.to raise_error "Unrecognised CCMS code: IM039"
        end
      end
    end

    def expected_response
      {
        request_id: "52fb18ad-257e-4ab1-91da-d7d5e4ff1068",
        success: true,
        proceedings: [
          {
            ccms_code: "DA004",
            matter_type: "Domestic abuse",
            gross_income_upper: true,
            disposable_income_upper: true,
            capital_upper: true,
            client_involvement_type: "A",
          },
          {
            ccms_code: "SE013",
            matter_type: "Children - section 8",
            gross_income_upper: false,
            disposable_income_upper: false,
            capital_upper: false,
            client_involvement_type: "D",
          },
          {
            ccms_code: "SE014",
            matter_type: "Children - section 8",
            gross_income_upper: false,
            disposable_income_upper: false,
            capital_upper: false,
            client_involvement_type: "I",
          },
          {
            ccms_code: "DA003",
            matter_type: "Domestic abuse",
            gross_income_upper: false,
            disposable_income_upper: false,
            capital_upper: false,
            client_involvement_type: "W",
          },
          {
            ccms_code: "SE003",
            matter_type: "Children - section 8",
            gross_income_upper: false,
            disposable_income_upper: false,
            capital_upper: false,
            client_involvement_type: "Z",
          },
        ],
      }
    end
  end
end

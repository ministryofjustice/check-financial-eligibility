require "rails_helper"

RSpec.describe LegalFrameworkAPI::ThresholdWaivers do
  before { allow(SecureRandom).to receive(:uuid).and_return(request_id) }

  describe ".call" do
    let(:proceeding_type_details) do
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

    let(:request_body) do
      {
        request_id:,
        proceedings: proceeding_type_details,
      }.to_json
    end

    let(:expected_parsed_response) do
      {
        request_id: "e76bd31f-dd62-444f-9d7d-a731b40b7eea",
        success: true,
        proceedings: [
          {
            ccms_code: "DA001",
            full_s8_only: false,
            matter_type: "Domestic abuse",
            gross_income_upper: true,
            disposable_income_upper: true,
            capital_upper: true,
            client_involvement_type: "A",
          },
          {
            ccms_code: "DA005",
            full_s8_only: false,
            client_involvement_type: "Z",
            gross_income_upper: false,
            disposable_income_upper: false,
            capital_upper: false,
            matter_type: "Domestic abuse",
          },
          {
            ccms_code: "SE014",
            full_s8_only: false,
            client_involvement_type: "A",
            gross_income_upper: false,
            disposable_income_upper: false,
            capital_upper: false,
            matter_type: "Children - section 8",
          },
        ],
      }
    end

    let(:expected_json_response) { expected_parsed_response.to_json }
    let(:request_id) { "e76bd31f-dd62-444f-9d7d-a731b40b7eea" }
    let(:api_endpoint) { "#{Rails.configuration.x.legal_framework_api_host}/#{described_class::ENDPOINT}" }

    context "successful API call", :vcr do
      it "responds to calling service with parsed response" do
        actual_response = described_class.call(proceeding_type_details)
        expect(actual_response).to eq expected_parsed_response
      end
    end

    context "unsuccessful API call" do
      it "raises ResponseError" do
        stub_request(:post, api_endpoint).with(body: request_body, headers:).to_return(body: "xxx", status: 500)
        expect {
          described_class.new(proceeding_type_details).call
        }.to raise_error Faraday::ServerError, "the server responded with status 500"
      end
    end

    def headers
      # The headers also include the Faraday version, but because that changes over time, we
      # don't specify that.  It just matches the headers we specify here
      {
        "Accept" => "*/*",
        "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
        "Content-Type" => "application/json",
      }
    end
  end
end

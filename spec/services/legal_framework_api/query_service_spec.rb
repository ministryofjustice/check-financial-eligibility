require "rails_helper"

module LegalFrameworkAPI
  RSpec.describe QueryService do
    context "class methods" do
      before { allow(SecureRandom).to receive(:uuid).and_return(request_id) }

      around do |example|
        VCR.turn_off!
        example.run
        VCR.turn_on!
      end

      let(:request_id) { "e76bd31f-dd62-444f-9d7d-a731b40b7eea" }
      let(:api_endpoint) { "#{Rails.configuration.x.legal_framework_api_host}/#{described_class::ENDPOINT}" }

      describe ".waived?" do
        let(:request) { request_waived(ccms_code) }

        context "a domestic abuse proceeding type" do
          let(:ccms_code) { :DA001 }

          it "returns true" do
            stub_request(:post, api_endpoint).with(body: request_body, headers:).to_return(body: expected_response, status: 200)
            expect(described_class.waived?(ccms_code, :capital_upper)).to be true
          end
        end

        context "a section 8 proceeding type" do
          let(:ccms_code) { :SE013 }

          it "returns true" do
            stub_request(:post, api_endpoint).with(body: request_body, headers:).to_return(body: expected_response, status: 200)
            expect(described_class.waived?(ccms_code, :disposable_income_upper)).to be false
          end
        end

        context "Unsuccessful response" do
          let(:ccms_code) { :DA003 }

          it "raises a ResponseError" do
            stub_request(:post, api_endpoint).with(body: request_body, headers:).to_return(body: "", status: 503)
            expect {
              described_class.waived?(ccms_code, :gross_income_upper)
            }.to raise_error LegalFrameworkAPI::ResponseError
          end
        end
      end

      describe ".matter_type" do
        let(:request) { request_waived(ccms_code) }

        context "a domestic abuse proceeding type" do
          let(:ccms_code) { :DA001 }

          it "returns true" do
            stub_request(:post, api_endpoint).with(body: request_body, headers:).to_return(body: expected_response, status: 200)
            expect(described_class.matter_type(ccms_code)).to eq "domestic_abuse"
          end
        end

        context "a section8 proceeding type" do
          let(:ccms_code) { :SE004 }

          it "returns true" do
            stub_request(:post, api_endpoint).with(body: request_body, headers:).to_return(body: expected_response, status: 200)
            expect(described_class.matter_type(ccms_code)).to eq "section8"
          end
        end
      end
    end

    def request_body
      {
        request_id: request_id,
        proceeding_types: [ccms_code]
      }.to_json
    end

    def expected_response
      matter_type = section8_code? ? "Children - section 8" : "Domestic abuse"
      threshold_waived = !section8_code?
      {
        request_id: request_id,
        proceeding_types: [
          {
            ccms_code:,
            matter_type:,
            capital_upper: threshold_waived,
            disposable_income_upper: threshold_waived,
            gross_income_upper: threshold_waived
          }
        ]
      }.to_json
    end

    def corrupted_response
      "{x = 33}"
    end

    def section8_code?
      /^SE/.match?(ccms_code)
    end

    def headers
      # The headers also include the Faraday version, but because that changes over time, we
      # don't specify that.  It just matches the headers we specify here
      {
        "Accept" => "*/*",
        "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
        "Content-Type" => "application/json"
      }
    end
  end
end

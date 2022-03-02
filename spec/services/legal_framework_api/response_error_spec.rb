module LegalFrameworkAPI
  RSpec.describe ResponseError do
    describe "#message" do
      let(:bad_response) { instance_double Faraday::Response, status: 500, body: "This is the body of the response" }

      it "formats the message" do
        error = described_class.new(bad_response)
        expect(error.message).to eq "Invalid response from Legal Framework API\nStatus: 500\nResponse: This is the body of the response"
      end
    end
  end
end

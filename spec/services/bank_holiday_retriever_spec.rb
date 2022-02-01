require "rails_helper"

RSpec.describe GovukBankHolidayRetriever do
  describe ".dates" do
    context "successful call" do
      before do
        stub_request(:get, "https://www.gov.uk/bank-holidays.json")
          .to_return(body: json_response, status: 200)
      end

      it "returns an array of dates for England and Wales" do
        expect(described_class.dates).to eq expected_dates
      end
    end

    context "unsuccessful call" do
      before do
        stub_request(:get, "https://www.gov.uk/bank-holidays.json")
          .to_return(body: "xxx", status: 404)
      end

      it "raises an error" do
        expect {
          described_class.dates
        }.to raise_error GovukBankHolidayRetriever::UnsuccessfulRetrievalError, "Retrieval Failed:  (404) xxx"
      end
    end

    def expected_dates
      %w[2015-01-01 2015-04-03 2015-04-06]
    end

    def json_response
      {
        "england-and-wales" => {
          "division" => "england-and-wales",
          "events" => [
            {
              "title" => "New Year’s Day",
              "date" => "2015-01-01",
              "notes" => "",
              "bunting" => true,
            },
            {
              "title" => "Good Friday",
              "date" => "2015-04-03",
              "notes" => "",
              "bunting" => false,
            },
            {
              "title" => "Easter Monday",
              "date" => "2015-04-06",
              "notes" => "",
              "bunting" => true,
            }
          ],
        },
        "scotland" => {
          "division" => "scotland",
          "events" => [
            {
              "title" => "New Year’s Day",
              "date" => "2015-01-01",
              "notes" => "",
              "bunting" => true,
            },
            {
              "title" => "2nd January",
              "date" => "2015-01-02",
              "notes" => "",
              "bunting" => true,
            },
            {
              "title" => "Good Friday",
              "date" => "2015-04-03",
              "notes" => "",
              "bunting" => false,
            }
          ],
        },
      }.to_json
    end
  end
end

require "rails_helper"

RSpec.describe Decorators::V5::VehicleDecorator do
  let(:purchase_date) { Date.new(2022, 8, 13) }
  let(:vehicle) do
    create :vehicle,
           value: 12_000.0,
           loan_amount_outstanding: 1250.44,
           date_of_purchase: purchase_date,
           in_regular_use: false,
           assessed_value: 0
  end

  subject(:decorator) { described_class.new(vehicle) }

  describe "#as_json" do
    it "returns hash in correct format" do
      expect(decorator.as_json).to eq expected_hash
    end

    it "renders as json correctly" do
      expect(decorator.as_json.to_json).to eq expected_json
    end

    def expected_hash
      {
        value: 12_000.0,
        loan_amount_outstanding: 1250.44,
        date_of_purchase: purchase_date,
        in_regular_use: false,
        included_in_assessment: false,
        disregards_and_deductions: 10_749.56,
        assessed_value: 0.0,
      }
    end

    def expected_json
      %({"value":12000.0,"loan_amount_outstanding":1250.44,"date_of_purchase":"2022-08-13","in_regular_use":false,"included_in_assessment":false,"disregards_and_deductions":10749.56,"assessed_value":0.0})
    end
  end
end

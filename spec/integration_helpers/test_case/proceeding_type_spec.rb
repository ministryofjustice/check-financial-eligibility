require "rails_helper"
require Rails.root.join("lib/integration_helpers/test_case/proceeding_type.rb")

module TestCase
  RSpec.describe ProceedingType do
    let(:rows) do
      [
        ["proceeding_types", "one", "proceeding_type_codes", "DA001", nil, nil, nil, nil, nil, nil],
        [nil, nil, "client_involvement_type", "A", nil, nil, nil, nil, nil, nil],
      ]
    end
    let(:expected_payload) do
      {
        ccms_code: "DA001",
        client_involvement_type: "A",
      }
    end

    describe "payload" do
      it "returns a hash suitable for sending to CFE" do
        pt = described_class.new(rows)
        expect(pt.payload).to eq(expected_payload)
      end
    end
  end
end

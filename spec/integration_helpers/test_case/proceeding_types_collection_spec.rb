require "rails_helper"
require Rails.root.join("lib/integration_helpers/test_case/proceeding_types_collection.rb")

module TestCase
  RSpec.describe ProceedingTypesCollection do
    let(:rows) do
      [
        ["proceeding_types", "one", "proceeding_type_codes", "DA001", nil, nil, nil, nil, nil, nil],
        [nil, nil, "client_involvement_type", "A", nil, nil, nil, nil, nil, nil],
        [nil, "two", "proceeding_type_codes", "SE013", nil, nil, nil, nil, nil, nil],
        [nil, nil, "client_involvement_type", "Z", nil, nil, nil, nil, nil, nil],
      ]
    end

    describe "initialize" do
      it "calls ProceedingType for each pair of rows" do
        expect(ProceedingType).to receive(:new).with(rows[0, 2]).and_call_original
        expect(ProceedingType).to receive(:new).with(rows[2, 2]).and_call_original
        described_class.new(rows)
      end
    end
  end
end

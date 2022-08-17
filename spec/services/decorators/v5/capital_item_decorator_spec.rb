require "rails_helper"

module Decorators
  module V5
    RSpec.describe CapitalItemDecorator do
      describe "#as_json" do
        subject(:decorator) { described_class.new(record).as_json }

        let(:record) { create :liquid_capital_item, value: 1283.66, description: "Ming vase" }

        it "returns expected hash" do
          expected_hash = {
            description: "Ming vase",
            value: 1283.66,
          }
          expect(decorator).to eq expected_hash
        end
      end
    end
  end
end

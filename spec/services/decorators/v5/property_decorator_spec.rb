require "rails_helper"

module Decorators
  module V5
    RSpec.describe PropertyDecorator do
      describe "#as_json" do
        subject(:json_hash) { described_class.new(property).as_json }

        context "property is nil" do
          let(:property) { nil }

          it "returns nil" do
            expect(json_hash).to be_nil
          end
        end

        context "property_exists" do
          let(:record) do
            create :property,
                   value: 785_900.0,
                   outstanding_mortgage: 454_533.64,
                   percentage_owned: 100.0,
                   main_home: true,
                   shared_with_housing_assoc: false
          end
          let(:property) do
            result = Calculators::PropertyCalculator.call(submission_date: Date.current, properties: [record],
                                                          level_of_help: "certificated", smod_cap: 100_000)
            PropertySubtotals.new result.first
          end

          it "returns the expected hash" do
            expected_hash = {
              value: 785_900.0,
              outstanding_mortgage: 454_533.64,
              percentage_owned: 100.0,
              main_home: true,
              shared_with_housing_assoc: false,
              transaction_allowance: 23_577.0,
              allowable_outstanding_mortgage: 454_533.64,
              net_value: 307_789.36,
              net_equity: 307_789.36,
              main_home_equity_disregard: 100_000,
              assessed_equity: 207_789.36,
              smod_allowance: 0,
            }
            expect(json_hash).to eq expected_hash
          end
        end
      end
    end
  end
end

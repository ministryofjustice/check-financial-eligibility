require "rails_helper"

module Decorators
  module V4
    RSpec.describe PropertyDecorator do
      describe "#as_json" do
        subject(:decorator) { described_class.new(record).as_json }

        context "property is nil" do
          let(:record) { nil }

          it "returns nil" do
            expect(decorator).to be_nil
          end
        end

        context "property_exists" do
          let(:record) do
            create :property,
                   value: 785_900.0,
                   outstanding_mortgage: 454_533.64,
                   percentage_owned: 100.0,
                   main_home: true,
                   shared_with_housing_assoc: false,
                   transaction_allowance: 23_577.0,
                   allowable_outstanding_mortgage: 65_000.0,
                   net_value: 697_523.0,
                   net_equity: 697_523.0,
                   main_home_equity_disregard: 100_000,
                   assessed_equity: 597_523.0
          end

          it "returns the expected hash" do
            expected_hash = {
              value: 785_900.0,
              outstanding_mortgage: 454_533.64,
              percentage_owned: 100.0,
              main_home: true,
              shared_with_housing_assoc: false,
              transaction_allowance: 23_577.0,
              allowable_outstanding_mortgage: 65_000.0,
              net_value: 697_523.0,
              net_equity: 697_523.0,
              main_home_equity_disregard: 100_000,
              assessed_equity: 597_523.0,
            }
            expect(decorator).to eq expected_hash
          end
        end
      end
    end
  end
end

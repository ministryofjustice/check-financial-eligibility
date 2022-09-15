require "rails_helper"

module Decorators
  module V5
    RSpec.describe CapitalSummaryDecorator do
      describe "#as_json" do
        subject(:decorator) { described_class.new(record).as_json }

        context "capital summary record is nil" do
          let(:record) { nil }

          it "returns nil" do
            expect(decorator).to be_nil
          end
        end

        context "capital summary decorator exists" do
          let(:record) { create :capital_summary, :with_everything, :with_eligibilities }

          it "has all expected keys in the returned hash" do
            expected_keys = %i[
              capital_items
              total_liquid
              total_non_liquid
              total_vehicle
              total_property
              total_mortgage_allowance
              total_capital
              pensioner_capital_disregard
              assessed_capital
              lower_threshold
              upper_threshold
              assessment_result
              capital_contribution
            ]
            expect(decorator.keys).to eq expected_keys
          end

          it "has expected keys int he capital items sections" do
            expected_keys = %i[liquid non_liquid vehicles properties]
            expect(decorator[:capital_items].keys).to eq expected_keys
          end

          it "has expected_keys in the properties section" do
            expected_keys = %i[main_home additional_properties]
            expect(decorator[:capital_items][:properties].keys).to eq expected_keys
          end

          it "calls property decorator expected numnber of times" do
            expected_count = record.additional_properties.count + 1 # add 1 for main home
            expect(PropertyDecorator).to receive(:new).and_return(instance_double("property_dec")).exactly(expected_count).times
            decorator
          end
        end
      end
    end
  end
end

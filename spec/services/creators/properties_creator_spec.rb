require "rails_helper"

module Creators
  RSpec.describe PropertiesCreator do
    let(:assessment) { create :assessment, :with_capital_summary }
    let(:capital_summary) { assessment.capital_summary }
    let(:assessment_id) { assessment.id }
    let(:main_home) do
      {
        value: 500_000,
        outstanding_mortgage: 200,
        percentage_owned: 15,
        shared_with_housing_assoc: true,
        subject_matter_of_dispute: true,
      }
    end
    let(:additional_properties) do
      [
        {
          value: 1_000,
          outstanding_mortgage: 0,
          percentage_owned: 99,
          shared_with_housing_assoc: false,
          subject_matter_of_dispute: false,
        },
        {
          value: 10_000,
          outstanding_mortgage: 40,
          percentage_owned: 80,
          shared_with_housing_assoc: true,
        },
      ]
    end
    let(:properties_params) do
      {
        properties: {
          main_home:,
          additional_properties:,
        },
      }.to_json
    end

    subject(:creator) do
      described_class.call(
        assessment_id:,
        properties_params:,
      )
    end

    describe ".call" do
      context "valid payload" do
        describe "#success?" do
          it "returns true" do
            expect(creator.success?).to be true
          end
        end

        describe "#properties" do
          it "returns array of properties" do
            expect(creator.properties.size).to eq 3
            expect(creator.properties.map(&:class).uniq).to eq [Property]
          end

          it "returns the ids of the new property records in the response" do
            expect(creator.properties.map(&:id)).to match_array capital_summary.properties.map(&:id)
          end
        end

        describe "#errors" do
          it "returns an empty array" do
            expect(creator.errors).to be_empty
          end
        end

        it "creates 3 property records for this assessment" do
          expect {
            creator
          }.to change { assessment.properties.count }.by(3)
        end
      end

      context "invalid assessment id" do
        let(:assessment_id) { SecureRandom.uuid }

        describe "#success?" do
          it "returns false" do
            expect(creator.success?).to be false
          end
        end

        it "returns errors" do
          expect(creator.errors.size).to eq 1
          expect(creator.errors.first).to eq "No such assessment id"
        end

        it "does not create any property records" do
          expect { creator }.not_to change(Property, :count)
        end
      end
    end
  end
end

require "rails_helper"

module Creators
  RSpec.describe CapitalsCreator do
    let(:assessment) { create :assessment, :with_capital_summary }
    let(:assessment_id) { assessment.id }
    let(:capital_summary) { assessment.capital_summary }
    let(:bank_accounts) { [] }
    let(:non_liquid_assets) { [] }
    let(:bank_name1)  { "#{Faker::Bank.name} #{Faker::Bank.account_number(digits: 8)}" }
    let(:bank_name2)  { "#{Faker::Bank.name} #{Faker::Bank.account_number(digits: 8)}" }
    let(:item1) { Faker::Appliance.equipment }
    let(:value1) { BigDecimal(Faker::Number.decimal(r_digits: 2), 2) }
    let(:value2) { BigDecimal(Faker::Number.decimal(r_digits: 2), 2) }

    subject(:creator) do
      described_class.call(
        assessment_id:,
        capital_params:,
      )
    end

    describe ".call" do
      context "with empty bank_accounts and non_liquid_capital" do
        let(:capital_params) { {}.to_json }

        it "returns an instance of CapitalCreationObject" do
          expect(creator).to be_instance_of(described_class)
        end

        it "does not create any capital item records" do
          expect(assessment.capital_summary.capital_items).to be_empty
        end
      end

      context "with liquid assets only" do
        let(:bank_accounts) { liquid_assets_hash }
        let(:capital_params) { bank_accounts.to_json }

        before { creator }

        it "creates liquid capital items" do
          expect(capital_summary.liquid_capital_items.size).to eq 2
          items = capital_summary.liquid_capital_items.order(:created_at)

          expect(items.first.description).to eq bank_name1
          expect(items.first.value).to eq value1
          expect(items.last.description).to eq bank_name2
          expect(items.last.value).to eq value2
        end

        it "does not create non-liquid capital items" do
          expect(capital_summary.non_liquid_capital_items).to be_empty
        end
      end

      context "non_liquid_capital_items_only" do
        let(:non_liquid_assets) { non_liquid_assets_hash }
        let(:capital_params) { non_liquid_assets.to_json }

        before { creator }

        it "creates non liquid capital items" do
          expect(capital_summary.non_liquid_capital_items.size).to eq 1
          expect(capital_summary.non_liquid_capital_items.first.description).to eq item1
          expect(capital_summary.non_liquid_capital_items.first.value).to eq value1
        end
      end

      context "with invalid capital item" do
        let(:capital_params) { invalid_liquid_assets_hash.to_json }

        before { creator }

        it "fails the schema validation" do
          expect(creator.errors).not_to be_empty
        end

        it "does not create any capital item records" do
          expect(assessment.capital_summary.capital_items).to be_empty
        end
      end
    end

    describe "#success?" do
      let(:capital_params) { {}.to_json }

      it "returns true" do
        expect(creator.success?).to be true
      end
    end

    describe "#capital_summary" do
      let(:capital_params) { liquid_assets_hash.merge(non_liquid_assets_hash).to_json }

      it "returns the created capital summary record" do
        result = creator.capital_summary
        expect(result).to be_instance_of(CapitalSummary)
      end
    end

    def liquid_assets_hash
      {
        "bank_accounts": [
          {
            description: bank_name1,
            value: value1,
          },
          {
            description: bank_name2,
            value: value2,
          },
        ],
      }
    end

    def non_liquid_assets_hash
      {
        "non_liquid_capital": [
          {
            description: item1,
            value: value1,
          },
        ],
      }
    end

    def invalid_liquid_assets_hash
      "bank_accounts"
    end

    context "no such assessment id" do
      let(:assessment_id) { SecureRandom.uuid }
      let(:capital_params) { {}.to_json }

      it "does not create capital_items" do
        expect { creator }.not_to change(CapitalItem, :count)
      end

      describe "#success?" do
        it "returns false" do
          expect(creator.success?).to be false
        end
      end

      describe "errors" do
        it "returns an error" do
          expect(creator.errors.size).to eq 1
          expect(creator.errors[0]).to eq "No such assessment id"
        end
      end
    end
  end
end

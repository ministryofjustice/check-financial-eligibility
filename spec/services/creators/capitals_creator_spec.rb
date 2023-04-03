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
    let(:smod_true) { true }
    let(:smod_false) { false }

    subject(:creator) do
      described_class.call(
        capital_params:,
        capital_summary: assessment.capital_summary,
      )
    end

    describe ".call" do
      context "with empty bank_accounts and non_liquid_capital" do
        let(:capital_params) { {} }

        it "does not create any capital item records" do
          expect(assessment.capital_summary.capital_items).to be_empty
        end
      end

      context "with liquid assets only" do
        let(:bank_accounts) { liquid_assets_hash }
        let(:capital_params) { bank_accounts }

        before { creator }

        it "creates liquid capital items" do
          expect(capital_summary.liquid_capital_items.size).to eq 2
          expect(capital_summary.liquid_capital_items.collect(&:description)).to match_array [bank_name1, bank_name2]
          expect(capital_summary.liquid_capital_items.collect(&:value)).to match_array [value1, value2]
          expect(capital_summary.liquid_capital_items.collect(&:subject_matter_of_dispute)).to match_array [smod_true, smod_false]
        end

        it "does not create non-liquid capital items" do
          expect(capital_summary.non_liquid_capital_items).to be_empty
        end
      end

      context "non_liquid_capital_items_only" do
        let(:non_liquid_assets) { non_liquid_assets_hash }
        let(:capital_params) { non_liquid_assets }

        before { creator }

        it "creates non liquid capital items" do
          expect(capital_summary.non_liquid_capital_items.size).to eq 1
          expect(capital_summary.non_liquid_capital_items.first.description).to eq item1
          expect(capital_summary.non_liquid_capital_items.first.value).to eq value1
          expect(capital_summary.non_liquid_capital_items.first.subject_matter_of_dispute).to eq smod_true
        end
      end
    end

    describe "#success?" do
      let(:capital_params) { {} }

      it "does not create any capital item records" do
        expect(assessment.capital_summary.capital_items).to be_empty
      end
    end

    def liquid_assets_hash
      {
        "bank_accounts": [
          {
            description: bank_name1,
            value: value1,
            subject_matter_of_dispute: smod_true,
          },
          {
            description: bank_name2,
            value: value2,
            subject_matter_of_dispute: smod_false,
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
            subject_matter_of_dispute: smod_true,
          },
        ],
      }
    end

    def invalid_liquid_assets_hash
      "bank_accounts"
    end
  end
end

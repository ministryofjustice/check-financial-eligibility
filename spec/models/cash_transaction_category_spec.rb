require "rails_helper"

describe CashTransactionCategory do
  let(:assessment) { create :assessment, :with_gross_income_summary }
  let(:gross_income_summary) { assessment.gross_income_summary }

  describe "validation" do
    let(:category) { described_class.new(gross_income_summary:, operation:, name:) }

    context "no name" do
      let(:operation) { nil }
      let(:name) { nil }

      it "is invalid" do
        expect(category).not_to be_valid
        expect(category.errors[:name]).to eq ["can't be blank"]
      end
    end

    context "operation credit" do
      let(:operation) { "credit" }

      context "invalid name" do
        let(:name) { "housing_costs" }

        it "is invalid" do
          expect(category).not_to be_valid
          expect(category.errors[:name]).to eq ["is not a valid credit category: housing_costs"]
        end
      end

      context "valid name" do
        let(:name) { "maintenance_in" }

        it "is valid" do
          expect(category).to be_valid
        end
      end
    end

    context "operation debit" do
      let(:operation) { "debit" }

      context "invalid name" do
        let(:name) { "benefits" }

        it "is invalid" do
          expect(category).not_to be_valid
          expect(category.errors[:name]).to eq ["is not a valid debit category: benefits"]
        end
      end

      context "valid name" do
        let(:name) { "legal_aid" }

        it "is valid" do
          expect(category).to be_valid
        end
      end
    end
  end
end

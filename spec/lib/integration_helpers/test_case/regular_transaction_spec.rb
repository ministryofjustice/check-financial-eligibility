require "rails_helper"
require Rails.root.join("lib/integration_helpers/test_case/regular_transaction.rb")

RSpec.describe TestCase::RegularTransaction do
  let(:instance) { described_class.new(category, data) }

  describe "#payload" do
    subject(:payload) { instance.payload }

    context "with a credit category" do
      let(:category) { "maintenance_in" }
      let(:data) do
        [
          %w[irrelevant irrelevant irrelevant 111.11],
          %w[irrelevant irrelevant irrelevant monthly],
        ]
      end

      it "returns a credit regular transaction payload" do
        expect(payload).to eq({
          category: "maintenance_in",
          operation: "credit",
          amount: "111.11",
          frequency: "monthly",
        })
      end
    end

    context "with a debit category" do
      let(:category) { "maintenance_out" }
      let(:data) do
        [
          %w[irrelevant irrelevant irrelevant 111.11],
          %w[irrelevant irrelevant irrelevant monthly],
        ]
      end

      it "returns a debit regular transaction payload" do
        expect(payload).to eq({
          category: "maintenance_out",
          operation: "debit",
          amount: "111.11",
          frequency: "monthly",
        })
      end
    end

    context "with a empty values" do
      let(:category) { "" }
      let(:data) { nil }

      it { expect(payload).to be_nil }
    end
  end
end

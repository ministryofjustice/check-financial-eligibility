require "rails_helper"
require Rails.root.join("lib/integration_helpers/test_case/regular_transactions_collection.rb")

RSpec.describe TestCase::RegularTransactionsCollection do
  let(:instance) { described_class.new(rows) }

  let(:with_rows) do
    [
      ["regular_transactions", "maintenance_in", "amount", 100.0, nil],
      [nil, nil, "frequency", "monthly", " monthly, four_weekly, two_weekly, weekly, unknown"],
      [nil, "maintenance_out", "amount", 100.0, nil],
      [nil, nil, "frequency", "monthly", " monthly, four_weekly, two_weekly, weekly, unknown"],
      ["not_regular_transactions", nil, nil, "irrelevant"],
    ]
  end

  describe "#url_method" do
    subject(:url_method) { instance.url_method }

    let(:rows) { with_rows }

    it { is_expected.to eq(:assessment_regular_transactions_path) }
  end

  describe "#payload" do
    subject(:payload) { instance.payload }

    context "with empty rows" do
      let(:rows) { [[]] }

      it "returns empty payload" do
        expect(payload).to match({ regular_transactions: [] })
      end
    end

    context "with rows" do
      let(:rows) { with_rows }

      it "returns expected payload" do
        expect(payload).to match({
          regular_transactions: [
            {
              category: "maintenance_in",
              operation: "credit",
              amount: 100.0,
              frequency: "monthly",
            },
            {
              category: "maintenance_out",
              operation: "debit",
              amount: 100.0,
              frequency: "monthly",
            },
          ],
        })
      end
    end
  end

  describe "#empty?" do
    subject { instance.empty? }

    context "with nil" do
      let(:rows) { nil }

      it { is_expected.to be true }
    end

    context "with empty rows" do
      let(:rows) { [[]] }

      it { is_expected.to be true }
    end

    context "with expected row data" do
      let(:rows) { with_rows }

      it { is_expected.to be false }
    end
  end
end

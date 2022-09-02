require "rails_helper"

RSpec.describe RegularTransaction, type: :model do
  it { is_expected.to belong_to(:gross_income_summary) }

  context "with all values as expected" do
    subject(:regular_transaction) { build(:regular_transaction) }

    it { is_expected.to be_valid }
  end

  context "with no category specified" do
    subject(:regular_transaction) { build(:regular_transaction, category: nil) }

    it "is invalid with expected error" do
      expect(regular_transaction).to be_invalid
      expect(regular_transaction.errors[:category]).to include("can't be blank")
    end
  end

  context "with no operation specified" do
    subject(:regular_transaction) { build(:regular_transaction, operation: nil) }

    it "is invalid with expected error" do
      expect(regular_transaction).to be_invalid
      expect(regular_transaction.errors[:operation]).to include("can't be blank")
    end
  end

  context "when operation is foobar" do
    subject(:regular_transaction) { build(:regular_transaction, operation: "foobar") }

    it "is invalid with expected error" do
      expect(regular_transaction).to be_invalid
      expect(regular_transaction.errors[:operation]).to include("foobar is not a valid operation")
    end
  end

  context "when operation is credit and category is a credit" do
    subject(:regular_transaction) { build(:regular_transaction, operation: "credit", category: "benefits") }

    it { is_expected.to be_valid }
  end

  context "when operation is credit but category is not a credit" do
    subject(:regular_transaction) { build(:regular_transaction, operation: "credit", category: "rent_or_mortgage") }

    it "is invalid" do
      expect(regular_transaction).to be_invalid
      expect(regular_transaction.errors[:category]).to eq ["is not a valid credit category: rent_or_mortgage"]
    end
  end

  context "when operation is debit and category is a debit" do
    subject(:regular_transaction) { build(:regular_transaction, operation: "debit", category: "rent_or_mortgage") }

    it { is_expected.to be_valid }
  end

  context "when operation is debit but category is not a debit" do
    subject(:regular_transaction) { build(:regular_transaction, operation: "debit", category: "benefits") }

    it "is invalid" do
      expect(regular_transaction).to be_invalid
      expect(regular_transaction.errors[:category]).to eq ["is not a valid debit category: benefits"]
    end
  end

  context "when category is not a credit or debit type" do
    subject(:regular_transaction) { build(:regular_transaction, operation: "credit", category: "foobar") }

    it "is invalid" do
      expect(regular_transaction).to be_invalid
      expect(regular_transaction.errors[:category]).to eq ["is not a valid credit category: foobar"]
    end
  end

  context "with valid frequency" do
    subject(:regular_transaction) { build(:regular_transaction, frequency: "monthly") }

    it { is_expected.to be_valid }
  end

  context "with frequency not included in list" do
    subject(:regular_transaction) { build(:regular_transaction, frequency: "quarterly") }

    it "is invalid" do
      expect(regular_transaction).to be_invalid
      expect(regular_transaction.errors[:frequency]).to eq ["is not a valid frequency: quarterly"]
    end
  end

  context "with blank frequency" do
    subject(:regular_transaction) { build(:regular_transaction, frequency: "") }

    it "is invalid" do
      expect(regular_transaction).to be_invalid
      expect(regular_transaction.errors[:frequency]).to include("can't be blank")
    end
  end

  describe "#credit?" do
    subject { regular_transaction.credit? }

    let(:regular_transaction) { build(:regular_transaction, operation:) }

    context "when operation is credit" do
      let(:operation) { "credit" }

      it { is_expected.to be_truthy }
    end

    context "when operation is debit" do
      let(:operation) { "debit" }

      it { is_expected.to be_falsey }
    end

    context "when operation is rubbish" do
      let(:operation) { "foobar" }

      it { is_expected.to be_falsey }
    end

    context "when operation is nil" do
      let(:operation) { nil }

      it { is_expected.to be_falsey }
    end
  end

  describe "#debit?" do
    subject { regular_transaction.debit? }

    let(:regular_transaction) { build(:regular_transaction, operation:) }

    context "when operation is debit" do
      let(:operation) { "debit" }

      it { is_expected.to be_truthy }
    end

    context "when operation is credit" do
      let(:operation) { "credit" }

      it { is_expected.to be_falsey }
    end

    context "when operation is rubbish" do
      let(:operation) { "foobar" }

      it { is_expected.to be_falsey }
    end

    context "when operation is nil" do
      let(:operation) { nil }

      it { is_expected.to be_falsey }
    end
  end
end

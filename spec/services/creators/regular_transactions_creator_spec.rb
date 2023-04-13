require "rails_helper"

RSpec.describe Creators::RegularTransactionsCreator do
  let(:assessment) { create(:assessment, :with_gross_income_summary) }

  shared_examples "unsuccessful creation" do |expected_error|
    it "does not create any records" do
      expect { creator }.not_to change(RegularTransaction, :count)
    end

    it "marks it as failure" do
      expect(creator).not_to be_success
    end

    if expected_error.present?
      it "returns expected error" do
        expect(creator.errors).to include(%r{#{expected_error}})
      end
    end
  end

  describe ".call" do
    subject(:creator) do
      described_class.call(gross_income_summary: assessment.gross_income_summary,
                           regular_transaction_params: params)
    end

    let(:valid_params) do
      { regular_transactions:
          [{ category: "maintenance_in",
             operation: "credit",
             amount: 9.99,
             frequency: "monthly" }] }
    end

    context "with valid payload" do
      let(:params) { valid_params }

      it "creates a regular transaction record" do
        expect { creator }.to change(assessment.gross_income_summary.regular_transactions, :count).by(1)
      end

      it "creates a regular transaction record with expected attributes" do
        creator
        regular_transaction = assessment.gross_income_summary.regular_transactions.last

        expect(regular_transaction).to have_attributes(category: "maintenance_in",
                                                       operation: "credit",
                                                       amount: 9.99,
                                                       frequency: "monthly")
      end
    end

    context "with invalid params" do
      let(:params) do
        { regular_transactions:
            [{ category: "something unknown",
               operation: "credit",
               amount: 9.99,
               frequency: "monthly" }] }
      end

      it_behaves_like "unsuccessful creation", "Category is not a valid credit category: something unknown"
    end

    context "with credit category in list" do
      let(:params) do
        { regular_transactions:
            [{ category: "benefits",
               operation: "credit",
               amount: 9.99,
               frequency: "monthly" }] }
      end

      it "creates a regular transaction record" do
        expect { creator }.to change(assessment.gross_income_summary.regular_transactions, :count).by(1)
      end
    end

    context "with debit category in list" do
      let(:params) do
        { regular_transactions:
            [{ category: "rent_or_mortgage",
               operation: "debit",
               amount: 9.99,
               frequency: "monthly" }] }
      end

      it "creates a regular transaction record" do
        expect { creator }.to change(assessment.gross_income_summary.regular_transactions, :count).by(1)
      end
    end

    context "with empty regular_transactions" do
      let(:params) { { regular_transactions: [] } }

      it "does not create any records" do
        expect { creator }.not_to change(RegularTransaction, :count)
      end

      it "marks it as success" do
        expect(creator).to be_success
      end

      it "does not add an error" do
        expect(creator.errors).to be_empty
      end
    end
  end
end

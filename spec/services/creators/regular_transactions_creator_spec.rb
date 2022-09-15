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
      described_class.call(assessment_id: assessment.id,
                           regular_transaction_params: params.to_json)
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

      it { expect(creator).to be_instance_of(described_class) }

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

    context "with invalid assessment id" do
      before { allow(assessment).to receive(:id).and_return("abcd") }

      let(:params) { valid_params }

      it_behaves_like "unsuccessful creation", "No such assessment id"
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

    context "with category not in list" do
      let(:params) do
        { regular_transactions:
            [{ category: "foobar",
               operation: "credit",
               amount: 9.99,
               frequency: "monthly" }] }
      end

      it_behaves_like "unsuccessful creation", "The property '#/regular_transactions/0/category' value \"foobar\" did not match one of the following values:"
    end

    context "with operation not in list" do
      let(:params) do
        { regular_transactions:
            [{ category: "rent_or_mortgage",
               operation: "foobar",
               amount: 9.99,
               frequency: "monthly" }] }
      end

      it_behaves_like "unsuccessful creation", "The property '#/regular_transactions/0/operation' value \"foobar\" did not match one of the following values: credit, debit"
    end

    context "with empty payload" do
      let(:params) { {} }

      it_behaves_like "unsuccessful creation", "The property '#/' did not contain a required property of 'regular_transactions' in schema file://public/schemas/regular_transactions.json"
    end

    context "with empty regular_transactions" do
      let(:params) { { regular_transactions: [] } }

      it "does not create any records" do
        expect { creator }.not_to change(RegularTransaction, :count)
      end

      it_behaves_like "unsuccessful creation", "The property '#/regular_transactions' did not contain a minimum number of items 1 in schema file://public/schemas/regular_transactions.json"
    end

    context "with missing required properties" do
      let(:params) { { regular_transactions: [{}] } }

      it_behaves_like "unsuccessful creation"

      it "returns expected errors" do
        expect(creator.errors)
          .to include(%r{The property '#/regular_transactions/0' did not contain a required property of 'category' in schema file://public/schemas/regular_transactions.json},
                      %r{The property '#/regular_transactions/0' did not contain a required property of 'operation' in schema file://public/schemas/regular_transactions.json},
                      %r{The property '#/regular_transactions/0' did not contain a required property of 'frequency' in schema file://public/schemas/regular_transactions.json},
                      %r{The property '#/regular_transactions/0' did not contain a required property of 'amount' in schema file://public/schemas/regular_transactions.json})
      end
    end

    context "with blank values" do
      let(:params) do
        { regular_transactions:
          [{ category: "",
             operation: "",
             frequency: "",
             amount: "" }] }
      end

      it_behaves_like "unsuccessful creation"

      it "returns expected errors" do
        expect(creator.errors)
          .to include(%r{The property '#/regular_transactions/0/category' value "" did not match one of the following values:},
                      %r{The property '#/regular_transactions/0/operation' value "" did not match one of the following values: credit, debit},
                      %r{The property '#/regular_transactions/0/frequency' value "" did not match one of the following values: three_monthly, monthly, four_weekly, two_weekly, weekly, unknown},
                      %r{The property '#/regular_transactions/0/amount' value "" did not match the regex})
      end
    end

    context "with nil amount" do
      let(:params) do
        { regular_transactions:
          [{ category: "maintenance_in",
             operation: "credit",
             frequency: "monthly",
             amount: nil }] }
      end

      it_behaves_like "unsuccessful creation", "The property '#/regular_transactions/0/amount' of type null matched the disallowed schema in"
    end
  end
end

require "rails_helper"

RSpec.describe RegularTransactionsController, type: :request do
  describe "POST assessments/:id/regular_transactions" do
    subject(:request) { post assessment_regular_transactions_path(assessment.id), params: params.to_json, headers: }

    let(:assessment) { create(:assessment, :with_gross_income_summary) }
    let(:headers) { { "CONTENT_TYPE" => "application/json" } }

    let(:valid_params) do
      { regular_transactions:
        [{ category: "maintenance_in",
           operation: "credit",
           amount: 9.99,
           frequency: "monthly" }] }
    end

    shared_examples "unsuccessful response" do |expected_error|
      it "responds with unprocessable status" do
        request
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "does not create the regular transaction record" do
        expect { request }.not_to change(RegularTransaction, :count)
      end

      it "response contains success false" do
        request
        expect(parsed_response[:success]).to be false
      end

      if expected_error.present?
        it "response contains expected error" do
          request
          expect(parsed_response[:errors]).to include(%r{#{expected_error}})
        end
      end
    end

    context "with valid payload" do
      let(:params) { valid_params }

      it "returns http success" do
        request
        expect(response).to have_http_status(:success)
      end

      it "creates the regular transaction" do
        expect { request }.to change(assessment.gross_income_summary.regular_transactions, :count).by(1)
      end

      it "response contains success true" do
        request
        expect(parsed_response[:success]).to be true
      end

      it "response contains no errors" do
        request
        expect(parsed_response[:errors]).to be_empty
      end
    end

    context "with invalid assessment_id" do
      before { allow(assessment).to receive(:id).and_return(SecureRandom.uuid) }

      let(:params) { valid_params }

      it_behaves_like "unsuccessful response", "No such assessment id"
    end

    context "with empty payload" do
      let(:params) { {} }

      it_behaves_like "unsuccessful response", "The property '#/' did not contain a required property of 'regular_transactions'"
    end

    context "with empty regular_transactions" do
      let(:params) { { regular_transactions: [] } }

      it "returns http success" do
        request
        expect(response).to have_http_status(:success)
      end

      it "response contains success true" do
        request
        expect(parsed_response[:success]).to be true
      end

      it "does not create the regular transaction record" do
        expect { request }.not_to change(RegularTransaction, :count)
      end
    end

    context "with missing required properties" do
      let(:params) { { regular_transactions: [{}] } }

      it_behaves_like "unsuccessful response"

      it "returns expected errors" do
        request
        expect(parsed_response[:errors])
          .to include(%r{The property '#/regular_transactions/0' did not contain a required property of 'category' in schema},
                      %r{The property '#/regular_transactions/0' did not contain a required property of 'operation' in schema},
                      %r{The property '#/regular_transactions/0' did not contain a required property of 'frequency' in schema},
                      %r{The property '#/regular_transactions/0' did not contain a required property of 'amount' in schema})
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

      it_behaves_like "unsuccessful response"

      it "returns expected errors" do
        request
        expect(parsed_response[:errors])
          .to include(/The property '#\/regular_transactions\/0\/category' value "foobar" did not match one of the following values:/)
      end
    end

    context "with operation not in list" do
      let(:params) do
        { regular_transactions:
            [{ category: "rent_or_mortgage",
               operation: "foobar",
               amount: 9.99,
               frequency: "monthly" }] }
      end

      it_behaves_like "unsuccessful response"

      it "returns expected errors" do
        request
        expect(parsed_response[:errors])
          .to include(/The property '#\/regular_transactions\/0\/operation' value "foobar" did not match one of the following values: credit, debit/)
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

      it_behaves_like "unsuccessful response"

      it "returns expected errors" do
        request
        expect(parsed_response[:errors])
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

      it_behaves_like "unsuccessful response"

      it "returns expected errors" do
        request
        expect(parsed_response[:errors])
          .to include(/The property '#\/regular_transactions\/0\/amount' of type null matched the disallowed schema/)
      end
    end
  end
end

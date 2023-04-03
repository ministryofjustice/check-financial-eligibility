require "rails_helper"

RSpec.describe IrregularIncomesController, type: :request do
  describe "POST irregular_income" do
    let(:assessment) { create :assessment, :with_gross_income_summary }
    let(:assessment_id) { assessment.id }
    let(:gross_income_summary) { assessment.gross_income_summary }
    let(:params) { irregular_income_params }
    let(:headers) { { "CONTENT_TYPE" => "application/json" } }
    let(:frequency) { "annual" }

    subject(:post_payload) { post assessment_irregular_incomes_path(assessment_id), params: params.to_json, headers: }

    context "valid payload" do
      it "returns http success" do
        post_payload
        expect(response).to have_http_status(:success)
      end

      context "student_loan" do
        it "creates the required number of IrregularIncomePayment records" do
          expect { post_payload }.to change(IrregularIncomePayment, :count).by(1)
          payments = gross_income_summary.irregular_income_payments
          expect(payments[0].income_type).to eq CFEConstants::STUDENT_LOAN
          expect(payments[0].frequency).to eq CFEConstants::ANNUAL_FREQUENCY
          expect(payments[0].amount).to eq 123_456.78
        end
      end

      it "generates a valid response" do
        post_payload
        expect(parsed_response[:success]).to eq true
        expect(parsed_response[:errors]).to be_empty
      end

      context "unspecified source income" do
        let(:params) do
          {
            payments: [
              {
                income_type: "unspecified_source",
                frequency: "quarterly",
                amount: 123_456.78,
              },
            ],
          }
        end

        it "creates the required number of IrregularIncomePayment records" do
          expect { post_payload }.to change(IrregularIncomePayment, :count).by(1)
          payments = gross_income_summary.irregular_income_payments
          expect(payments[0].income_type).to eq CFEConstants::UNSPECIFIED_SOURCE
          expect(payments[0].frequency).to eq CFEConstants::QUARTERLY_FREQUENCY
          expect(payments[0].amount).to eq 123_456.78
        end
      end
    end

    context "invalid_payload" do
      context "invalid payload - missing frequency" do
        let(:params) do
          {
            payments: [
              {
                income_type: "student_loan",
                amount: 99_999.00,
              },
            ],
          }
        end

        before do
          post_payload
        end

        it "does not creat any records" do
          expect(IrregularIncomePayment.count).to eq(0)
        end

        it "returns an error" do
          expect(parsed_response[:errors]).to eq ["The property '#/payments/0' did not contain a required property of 'frequency' in schema file://public/schemas/irregular_incomes.json"]
        end
      end

      context "invalid payload - multiple payments" do
        let(:params) do
          {
            payments: [
              {
                income_type: "student_loan",
                frequency:,
                amount: 123_456.78,
              },
              {
                income_type: "student_loan",
                frequency:,
                amount: 123_456.78,
              },
              {
                income_type: "unspecified_source",
                frequency:,
                amount: 123_456.78,
              },
            ],
          }
        end

        before do
          post_payload
        end

        it "does not creat any records" do
          expect(IrregularIncomePayment.count).to eq(0)
        end

        it "returns an error" do
          expect(parsed_response[:errors]).to eq ["The property '#/payments' had more items than the allowed 2 in schema file://public/schemas/irregular_incomes.json"]
        end
      end

      context "missing income_type in params" do
        let(:params) do
          new_hash = irregular_income_params
          new_hash[:payments].first.delete(:income_type)
          new_hash
        end

        it "returns unprocessable" do
          post_payload
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "contains success false in the response body" do
          post_payload
          expect(parsed_response).to eq(success: false, errors: ["The property '#/payments/0' did not contain a required property of 'income_type' in schema file://public/schemas/irregular_incomes.json"])
        end

        it "does not create irregular income payment record" do
          expect { post_payload }.not_to change(IrregularIncomePayment, :count)
        end
      end

      context "invalid irregular income payment type" do
        let(:params) do
          new_hash = irregular_income_params
          new_hash[:payments].first[:income_type] = "imagined_type"
          new_hash
        end

        it "returns unsuccessful" do
          post_payload
          expect(response.status).to eq 422
        end

        it "contains success false in the response body" do
          post_payload
          expect(parsed_response[:success]).to be false
        end

        it "contains an error message" do
          post_payload
          expect(parsed_response).to eq({ success: false, errors: ["The property '#/payments/0/income_type' value \"imagined_type\" did not match one of the following values: student_loan, unspecified_source in schema file://public/schemas/irregular_incomes.json"] })
        end

        it "does not create irregular income payments record" do
          expect { post_payload }.not_to change(IrregularIncomePayment, :count)
        end
      end
    end

    context "invalid_assessment_id" do
      let(:assessment_id) { SecureRandom.uuid }

      it "returns unsuccessful" do
        post_payload
        expect(response.status).to eq 422
      end

      it "contains success false in the response body" do
        post_payload
        expect(parsed_response).to eq(errors: ["No such assessment id"], success: false)
      end
    end

    def irregular_income_params
      {
        payments: [
          {
            income_type: "student_loan",
            frequency: "annual",
            amount: 123_456.78,
          },
        ],
      }
    end
  end
end

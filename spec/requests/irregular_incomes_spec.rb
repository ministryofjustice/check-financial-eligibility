require "rails_helper"

RSpec.describe IrregularIncomesController, type: :request do
  describe "POST irregular_income" do
    let(:assessment) { create :assessment, :with_gross_income_summary }
    let(:assessment_id) { assessment.id }
    let(:gross_income_summary) { assessment.gross_income_summary }
    let(:params) { irregular_income_params }
    let(:headers) { { "CONTENT_TYPE" => "application/json" } }

    subject { post assessment_irregular_incomes_path(assessment_id), params: params.to_json, headers: headers }

    context "valid payload" do
      it "returns http success", :show_in_doc do
        subject
        expect(response).to have_http_status(:success)
      end

      context "student_loan" do
        it "creates the required number of IrregularIncomePayment records" do
          expect { subject }.to change(IrregularIncomePayment, :count).by(1)
          payments = gross_income_summary.irregular_income_payments
          expect(payments[0].income_type).to eq CFEConstants::STUDENT_LOAN
          expect(payments[0].frequency).to eq CFEConstants::ANNUAL_FREQUENCY
          expect(payments[0].amount).to eq 123_456.78
        end
      end

      it "generates a valid response" do
        subject
        expect(parsed_response[:success]).to eq true
        expect(parsed_response[:errors]).to be_empty
      end
    end

    context "invalid_payload" do
      context "missing income_type in params" do
        let(:params) do
          new_hash = irregular_income_params
          new_hash[:payments].first.delete(:income_type)
          new_hash
        end

        it "returns unprocessable", :show_in_doc do
          subject
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "contains success false in the response body" do
          subject
          expect(parsed_response).to eq(errors: ["Missing parameter income_type"], success: false)
        end

        it "does not create irregular income payment record" do
          expect { subject }.not_to change(IrregularIncomePayment, :count)
        end
      end

      context "invalid irregular income payment type" do
        let(:params) do
          new_hash = irregular_income_params
          new_hash[:payments].first[:income_type] = "imagined_type"
          new_hash
        end

        it "returns unsuccessful" do
          subject
          expect(response.status).to eq 422
        end

        it "contains success false in the response body" do
          subject
          expect(parsed_response[:success]).to be false
        end

        it "contains an error message" do
          subject
          expect(parsed_response[:errors].first).to match(/Invalid parameter 'income_type'/)
        end

        it "contains success false in the response body" do
          subject
          expect(parsed_response).to eq(errors: ["Invalid parameter 'income_type' value \"imagined_type\": Must be one of: <code>student_loan</code>."], success: false)
        end

        it "does not create irregular income payments record" do
          expect { subject }.not_to change(IrregularIncomePayment, :count)
        end
      end
    end

    context "invalid_assessment_id" do
      let(:assessment_id) { SecureRandom.uuid }

      it "returns unsuccessful" do
        subject
        expect(response.status).to eq 422
      end

      it "contains success false in the response body" do
        subject
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
          }
        ],
      }
    end
  end
end

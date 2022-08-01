require "rails_helper"

RSpec.describe StateBenefitsController, type: :request do
  describe "POST state_benefit" do
    let(:assessment) { create :assessment, :with_gross_income_summary }
    let(:assessment_id) { assessment.id }
    let(:gross_income_summary) { assessment.gross_income_summary }
    let(:params) { state_benefit_params }
    let(:headers) { { "CONTENT_TYPE" => "application/json" } }
    let(:client_ids) { [SecureRandom.uuid, SecureRandom.uuid, SecureRandom.uuid] }

    let!(:state_benefit_type1) { create :state_benefit_type }
    let!(:state_benefit_type2) { create :state_benefit_type }

    subject(:post_payload) { post assessment_state_benefits_path(assessment_id), params: params.to_json, headers: }

    context "valid payload" do
      context "with two state benefits" do
        it "returns http success" do
          post_payload
          expect(response).to have_http_status(:success)
        end

        it "generates a valid response" do
          post_payload
          expect(parsed_response[:success]).to eq true
          expect(parsed_response[:errors]).to be_empty
        end

        it "creates two state benefit records" do
          expect { post_payload }.to change { gross_income_summary.state_benefits.count }.by(2)
          state_benefit_types = gross_income_summary.state_benefits.map(&:state_benefit_type)
          expect(state_benefit_types).to match_array([state_benefit_type1, state_benefit_type2])
        end

        it "creates state benefit payment records" do
          expect { post_payload }.to change(StateBenefitPayment, :count).by(6)
        end

        it "creates payment records with correct values" do
          post_payload
          state_benefit = gross_income_summary.state_benefits.detect { |sb| sb.state_benefit_type == state_benefit_type1 }
          payments = state_benefit.state_benefit_payments.order(:payment_date)
          expect(payments.first.payment_date).to eq Date.parse("2019-09-01")
        end

        it "stores the given client id if provided in the params" do
          post_payload
          state_benefit = gross_income_summary.state_benefits.detect { |sb| sb.state_benefit_type == state_benefit_type1 }
          expect(state_benefit.state_benefit_payments.map(&:client_id)).to match client_ids
        end

        context "when the flags field contains multi_benefit" do
          it "sets the multi_benefit flag" do
            post_payload
            state_benefit = gross_income_summary.state_benefits.detect { |sb| sb.state_benefit_type == state_benefit_type2 }
            expect(state_benefit.state_benefit_payments.map(&:flags)).to match [false, false, %w[multi_benefit]]
          end
        end
      end
    end

    context "invalid_payload" do
      context "missing source in the second element" do
        let(:params) do
          new_hash = state_benefit_params
          new_hash[:state_benefits].last.delete(:name)
          new_hash
        end

        it "returns unsuccessful" do
          post_payload
          expect(response.status).to eq 422
        end

        it "contains success false in the response body" do
          post_payload
          expect(parsed_response).to match(errors: [/The property '#\/state_benefits\/1' did not contain a required property of 'name' in schema file/], success: false)
        end

        it "does not create any state benefit records" do
          expect { post_payload }.not_to change(StateBenefit, :count)
        end
      end

      context "missing required parameter client_id" do
        let(:params) do
          new_hash = state_benefit_params
          new_hash[:state_benefits].last[:payments].first.delete(:client_id)
          new_hash
        end

        it "returns unsuccessful" do
          post_payload
          expect(response.status).to eq 422
        end

        it "contains success false in the response body" do
          post_payload
          expect(parsed_response).to match(errors: [/The property '#\/state_benefits\/1\/payments\/0' did not contain a required property of 'client_id' in schema file/], success: false)
        end

        it "does not create any other income source records" do
          expect { post_payload }.not_to change(OtherIncomeSource, :count)
        end

        it "does not create any other income payment records" do
          expect { post_payload }.not_to change(OtherIncomePayment, :count)
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

    def state_benefit_params
      {
        state_benefits: [
          {
            name: state_benefit_type1.label,
            payments: [
              {
                date: "2019-11-01",
                amount: 1046.44,
                client_id: client_ids[0],
              },
              {
                date: "2019-10-01",
                amount: 1034.33,
                client_id: client_ids[1],
              },
              {
                date: "2019-09-01",
                amount: 1033.44,
                client_id: client_ids[2],
              },
            ],
          },
          {
            name: state_benefit_type2.label,
            payments: [
              {
                date: "2019-11-01",
                amount: 250.00,
                client_id: client_ids[0],
              },
              {
                date: "2019-10-01",
                amount: 266.02,
                client_id: client_ids[1],
              },
              {
                date: "2019-09-01",
                amount: 250.00,
                client_id: client_ids[2],
                flags: {
                  multi_benefit: true,
                },
              },
            ],
          },
        ],
      }
    end
  end
end

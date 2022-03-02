require "rails_helper"

RSpec.describe ExplicitRemarksController, type: :request do
  describe "POST /assessments/:assessment_id/remarks" do
    let(:assessment) { create :assessment }
    let(:headers) { { "CONTENT_TYPE" => "application/json" } }
    let(:request_payload) do
      {
        explicit_remarks: [
          {
            category: "policy_disregards",
            details: %w[
              employment
              charity
            ],
          },
        ],
      }
    end

    context "valid payload" do
      before do
        post assessment_explicit_remarks_path(assessment.id), params: payload.to_json, headers: headers
      end

      context " success", :show_in_doc do
        let(:payload) { valid_payload }

        it "successful" do
          expect(response).to be_successful
        end
      end

      context "invalid payload" do
        let(:payload) { invalid_payload }

        it "is not successful", :show_in_doc do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "shows errors in the response" do
          parsed_response = JSON.parse(response.body, symbolize_names: true)
          expect(parsed_response[:success]).to be false
          expect(parsed_response[:errors].size).to eq 1
          expect(parsed_response[:errors].first).to eq %(Invalid parameter 'category' value "other_stuff": Must be one of: <code>policy_disregards</code>.)
        end
      end

      context "error in creation service" do
        let(:payload) { valid_payload }

        it "returns unprocessable entity" do
          allow_any_instance_of(Creators::ExplicitRemarksCreator).to receive(:success?).and_return(false)
          post assessment_explicit_remarks_path(assessment.id), params: payload.to_json, headers: headers
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    def valid_payload
      {
        explicit_remarks: [
          {
            category: "policy_disregards",
            details: %w[
              employment
              charity
            ],
          },
        ],
      }
    end

    def invalid_payload
      {
        explicit_remarks: [
          {
            category: "other_stuff",
            details: %w[
              employment
              charity
            ],
          },
        ],
      }
    end
  end
end

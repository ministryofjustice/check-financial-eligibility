require "rails_helper"

RSpec.describe ExplicitRemarksController, type: :request do
  describe "POST /assessments/:assessment_id/remarks" do
    let(:assessment) { create :assessment }
    let(:headers) { { "CONTENT_TYPE" => "application/json" } }

    let(:valid_payload) do
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

    context "with valid payload" do
      let(:payload) { valid_payload }
      let(:assessment_id) { assessment.id }

      before do
        post assessment_explicit_remarks_path(assessment_id), params: payload.to_json, headers:
      end

      it "returns success" do
        expect(response).to have_http_status(:success)
        expect(parsed_response[:success]).to be true
      end

      it "parsed responses errors empty true" do
        expect(parsed_response[:errors]).to be_empty
      end

      context "but no assessment_id " do
        let(:assessment_id) { "fake-uuid" }

        it "returns failure" do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "parsed responses contains errors" do
          expect(parsed_response).to eq(success: false, errors: ["Assessment must exist"])
        end
      end
    end

    context "with valid payload but error in creation service" do
      let(:payload) { valid_payload }

      before do
        allow_any_instance_of(Creators::ExplicitRemarksCreator).to receive(:success?).and_return(false)
        post assessment_explicit_remarks_path(assessment.id), params: payload.to_json, headers:
      end

      it "returns unprocessable entity" do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "with no explicit_remarks" do
      let(:payload) { {} }

      before do
        post assessment_explicit_remarks_path(assessment.id), params: payload.to_json, headers:
      end

      it { expect(response).to have_http_status(:unprocessable_entity) }

      it "parsed responses contains errors" do
        expect(parsed_response[:errors]).to include(%r{The property '#/' did not contain a required property of 'explicit_remarks'})
      end
    end

    context "with invalid explicit_remark category" do
      let(:payload) do
        {
          explicit_remarks: [
            {
              category: "other_stuff",
            },
          ],
        }
      end

      before do
        post assessment_explicit_remarks_path(assessment.id), params: payload.to_json, headers:
      end

      it "returns failure" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response[:success]).to be false
      end

      it "parsed responses contains errors" do
        expect(parsed_response[:errors]).to include(%r{The property '#/explicit_remarks/0/category' value "other_stuff" did not match one of the following values: policy_disregards})
      end
    end

    context "with no explicit_remark details" do
      let(:payload) do
        {
          explicit_remarks: [
            {
              category: "policy_disregards",
            },
          ],
        }
      end

      before do
        post assessment_explicit_remarks_path(assessment.id), params: payload.to_json, headers:
      end

      it "returns failure" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response[:success]).to be false
      end

      it "parsed responses contains errors" do
        expect(parsed_response[:errors]).to include(%r{The property '#/explicit_remarks/0' did not contain a required property of 'details'})
      end
    end
  end
end

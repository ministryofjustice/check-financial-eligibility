require "rails_helper"

RSpec.describe PropertiesController, type: :request do
  describe "POST /assessments/:assessment_id/properties" do
    let(:assessment) { create :assessment, :with_capital_summary }
    let(:assessment_id) { assessment.id }
    let(:property) { create :property, assessment: assessment }
    let(:headers) { { "CONTENT_TYPE" => "application/json" } }
    let(:request_payload) do
      {
        properties: {
          main_home: {
            value: 500_000,
            outstanding_mortgage: 200,
            percentage_owned: 15,
            shared_with_housing_assoc: true,
          },
          additional_properties: [
            {
              value: 1000,
              outstanding_mortgage: 0,
              percentage_owned: 99,
              shared_with_housing_assoc: false,
            },
            {
              value: 10_000,
              outstanding_mortgage: 40,
              percentage_owned: 80,
              shared_with_housing_assoc: true,
            }
          ],
        },
      }
    end

    context "valid payload" do
      before do
        post assessment_properties_path(assessment_id), params: request_payload.to_json, headers: headers
      end

      context "service returns success" do
        it "returns http status code 200", :show_in_doc do
          expect(response).to have_http_status(:success)
        end

        it "generates a valid response" do
          expect(parsed_response[:success]).to eq true
          expect(parsed_response[:errors]).to be_empty
        end
      end

      context "Invalid assessment ID causes service to return failure" do
        let(:assessment_id) { SecureRandom.uuid }

        it "returns expected error response", :show_in_doc do
          expect(parsed_response[:success]).to eq(false)
          expect(parsed_response[:errors]).to eq [%(No such assessment id)]
        end

        it "returns 422" do
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end
end

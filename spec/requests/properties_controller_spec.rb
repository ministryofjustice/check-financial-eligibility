require "rails_helper"

RSpec.describe PropertiesController, type: :request do
  describe "POST /assessments/:assessment_id/properties" do
    let(:assessment) { create :assessment, :with_capital_summary }
    let(:assessment_id) { assessment.id }
    let(:property) { create :property, assessment: }
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
            },
          ],
        },
      }
    end

    before do
      post assessment_properties_path(assessment_id), params: request_payload.to_json, headers:
    end

    context "with valid payload" do
      let(:assessment_id) { assessment.id }

      it "returns http status code 200" do
        expect(response).to have_http_status(:success)
      end

      it "parsed response returns success true" do
        expect(parsed_response[:success]).to eq true
      end

      it "parsed response returns no errors" do
        expect(parsed_response[:errors]).to be_empty
      end
    end

    context "with invalid assessment ID" do
      let(:assessment_id) { SecureRandom.uuid }

      it "returns http status 422" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns expected error response" do
        expect(parsed_response).to eq(success: false, errors: [%(No such assessment id)])
      end

      context "with missing main_home attribute" do
        let(:request_payload) { { properties: {} } }

        it "returns http status 422" do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "parsed response returns success false" do
          expect(parsed_response[:success]).to eq false
        end

        it "returns expected error response" do
          expect(parsed_response[:errors]).to match [/The property '#\/properties' did not contain a required property of 'main_home'/]
        end
      end

      context "with invalid main_home value attribute" do
        let(:request_payload) do
          {
            properties: {
              main_home: {
                value: "one hundred pounds",
                outstanding_mortgage: 200,
                percentage_owned: 15,
                shared_with_housing_assoc: true,
              },
            },
          }
        end

        it "returns http status 422" do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "parsed response returns success false" do
          expect(parsed_response[:success]).to eq false
        end

        it "returns expected error response" do
          expect(parsed_response[:errors]).to match [/The property '#\/properties\/main_home\/value' value "one hundred pounds" did not match the regex/]
        end
      end

      context "with missing main_home outstanding_mortgage attribute" do
        let(:request_payload) do
          {
            properties: {
              main_home: {
                value: 500_000,
                percentage_owned: 15,
                shared_with_housing_assoc: true,
              },
            },
          }
        end

        it "returns http status 422" do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "parsed response returns success false" do
          expect(parsed_response[:success]).to eq false
        end

        it "returns expected error response" do
          expect(parsed_response[:errors]).to match [/The property '#\/properties\/main_home' did not contain a required property of 'outstanding_mortgage'/]
        end
      end

      context "with missing additional_properties percentage_owned attribute" do
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
                  shared_with_housing_assoc: false,
                },
              ],
            },
          }
        end

        it "returns http status 422" do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "parsed response returns success false" do
          expect(parsed_response[:success]).to eq false
        end

        it "returns expected error response" do
          expect(parsed_response[:errors]).to match [/The property '#\/properties\/additional_properties\/0' did not contain a required property of 'percentage_owned'/]
        end
      end

      context "with invalid additional_properties shared_with_housing_assoc attribute" do
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
                  shared_with_housing_assoc: "false",
                },
              ],
            },
          }
        end

        it "returns http status 422" do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "parsed response returns success false" do
          expect(parsed_response[:success]).to eq false
        end

        it "returns expected error response" do
          expect(parsed_response[:errors]).to match [/The property '#\/properties\/additional_properties\/0\/shared_with_housing_assoc' of type string did not match the following type: boolean/]
        end
      end
    end
  end
end

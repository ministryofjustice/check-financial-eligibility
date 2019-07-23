require 'rails_helper'

RSpec.describe PropertiesController, type: :request do
  describe 'POST /assessments/:assessment_id/properties' do
    let(:assessment) { create :assessment }
    let(:property) { create :property, assessment: assessment }
    let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }
    let(:request_payload) do
      {
        assessment_id: assessment.id,
        properties: {
          main_home: {
            value: 500_000,
            outstanding_mortgage: 200,
            percentage_owned: 15,
            shared_with_housing_assoc: true
          },
          additional_properties: [
            {
              value: 1000,
              outstanding_mortgage: 0,
              percentage_owned: 99,
              shared_with_housing_assoc: false
            },
            {
              value: 10_000,
              outstanding_mortgage: 40,
              percentage_owned: 80,
              shared_with_housing_assoc: true
            }
          ]
        }
      }
    end

    context 'valid payload' do
      before do
        post assessment_properties_path(assessment.id), params: request_payload.to_json, headers: headers
      end

      context 'service returns success' do
        it 'returns http status code 200', :show_in_doc do
          expect(response).to have_http_status(:success)
        end

        it 'returns the expected success response payload' do
          ap parsed_response
          expect(parsed_response[:success]).to eq(true)
          expect(parsed_response[:errors]).to be_empty
          expect(parsed_response[:objects].size).to eq 3
          expect(parsed_response[:objects].first[:assessment_id]).to eq assessment.id
          expect(parsed_response[:objects].first[:shared_with_housing_assoc]).to be true
          expect(parsed_response[:objects].last[:main_home]).to be false
          expect(parsed_response[:objects].last[:shared_with_housing_assoc]).to be true
        end
      end

      context 'Invalid assessment ID causes service to return failure' do
        let(:non_existent_assessment_id) { SecureRandom.uuid }
        let(:request_payload) do
          {
            assessment_id: non_existent_assessment_id,
            properties: {
              main_home: {
                value: 123_456,
                outstanding_mortgage: 3000,
                percentage_owned: 20,
                shared_with_housing_assoc: true
              }
            }
          }
        end

        it 'returns expected error response', :show_in_doc do
          expect(parsed_response[:success]).to eq(false)
          expect(parsed_response[:errors]).to eq [%(No such assessment id)]
          expect(parsed_response[:objects]).to be_nil
        end

        it 'returns 422' do
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end
end

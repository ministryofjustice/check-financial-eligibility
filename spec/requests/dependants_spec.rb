require 'rails_helper'

RSpec.describe DependantsController, type: :request do
  describe 'POST dependants' do
    let(:assessment) { create :assessment }
    let(:dependants) { create_list :dependant, 2, assessment: assessment }
    let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }
    let(:request_payload) do
      {
        assessment_id: assessment.id,
        dependants: [
          {
            date_of_birth: 12.years.ago.to_date,
            in_full_time_education: true
          },
          {
            date_of_birth: 20.years.ago.to_date,
            in_full_time_education: false,
            income: [
              {
                date_of_payment: 60.days.ago.to_date,
                amount: 66.66
              },
              {
                date_of_payment: 40.days.ago.to_date,
                amount: 44.44
              },
              {
                date_of_payment: 20.days.ago.to_date,
                amount: 22.22
              }
            ]
          }
        ]
      }
    end

    context 'valid payload' do
        before { post assessment_dependants_path(assessment), params: request_payload.to_json, headers: headers }

        it 'returns http success', :show_in_doc do
          expect(response).to have_http_status(:success)
        end

        it 'generates a valid response' do
          expect(parsed_response[:success]).to eq(true)
          expect(parsed_response[:errors]).to be_empty
          expect(parsed_response[:objects]).not_to be_empty
          # expect(parsed_response[:objects].first[:id]).to eq(dependants.first.id)
        end
      end

    context 'empty payload' do
      let(:request_payload) { {} }

      before { post assessment_dependants_path(assessment), params: request_payload.to_json, headers: headers }

      it 'returns http unprocessable entity' do
       expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error payload' do
       expect(parsed_response[:success]).to eq(false)
       expect(parsed_response[:errors]).to_not be_empty
       # expect(parsed_response[:objects][:date_of_birth]).to be_empty
       # expect(parsed_response[:objects][:in_full_time_education]).to be_empty
      end
    end

    context 'invalid payload' do
      let(:request_payload) do
        {
          assessment_id: assessment.id,
          dependants: [
            {
              date_of_birth: nil,
              in_full_time_education: nil
            },
          ]
        }
      end

      before { post assessment_dependants_path(assessment), params: request_payload.to_json, headers: headers }

      it 'returns http unprocessable entity' do
       expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error payload' do
       expect(parsed_response[:success]).to eq(false)
       expect(parsed_response[:errors]).to_not be_empty
      end
    end

    context 'invalid assessment_id' do
      let(:non_existent_assessment_id) { SecureRandom.uuid }
      let(:request_payload) do
        {
          assessment_id: non_existent_assessment_id,
          dependants: [
            {
              date_of_birth: 8.years.ago.to_date,
              in_full_time_education: true
            },
          ]
        }
      end

      before { post assessment_dependants_path(assessment), params: request_payload.to_json, headers: headers }

      it 'returns http unprocessable entity' do
       expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error payload' do
       expect(parsed_response[:success]).to eq(false)
       expect(parsed_response[:errors]).to_not be_empty
      end
    end
  end
end

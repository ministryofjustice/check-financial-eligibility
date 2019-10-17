require 'rails_helper'

RSpec.describe ApplicantsController, type: :request do
  describe 'POST applicants' do
    let(:assessment) { create :assessment }
    let(:applicant) { 'applicant' }
    let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }
    let(:params) do
      {
        applicant: {
          date_of_birth: 20.years.ago.to_date,
          involvement_type: 'applicant',
          has_partner_opponent: false,
          receives_qualifying_benefit: true
        }
      }
    end

    context 'valid payload' do
      before do
        post assessment_applicant_path(assessment.id), params: params.to_json, headers: headers
      end

      context 'service returns success' do
        it 'returns success', :show_in_doc do
          expect(response).to have_http_status(:success)
        end

        it 'returns expected response' do
          expect(parsed_response[:success]).to eq(true)
          expect(parsed_response[:errors]).to be_empty
          expect(parsed_response[:objects].size).to eq 1
          expect(parsed_response[:objects].first[:date_of_birth]).to eq 20.years.ago.to_date.strftime('%Y-%m-%d')
          expect(parsed_response[:objects].first[:assessment_id]).to eq assessment.id
          expect(parsed_response[:objects].first[:involvement_type]).to eq 'applicant'
          expect(parsed_response[:objects].first[:has_partner_opponent]).to be false
          expect(parsed_response[:objects].first[:receives_qualifying_benefit]).to be true
        end
      end

      context 'service returns failure' do
        let(:future_date) { 4.years.from_now.to_date }
        let(:future_date_string) { future_date.strftime('%Y-%m-%d') }
        let(:params) do
          {
            assessment_id: assessment.id,
            applicant: {
              date_of_birth: future_date,
              involvement_type: 'applicant',
              has_partner_opponent: false,
              receives_qualifying_benefit: true
            }
          }
        end
        let(:expected_message) do
          %(Invalid parameter 'date_of_birth' value "#{future_date_string}": Date must be parsable and in the past. For example: '2019-05-23')
        end

        it 'returns 422' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'returns expected response' do
          expect(parsed_response[:success]).to eq(false)
          expect(parsed_response[:errors]).to eq [expected_message]
          expect(parsed_response[:objects]).to be_nil
        end
      end
    end

    context 'invalid payload' do
      let(:non_existent_assessment_id) { SecureRandom.uuid }
      before do
        params[:assessment_id] = non_existent_assessment_id
        post assessment_applicant_path(non_existent_assessment_id), params: params.to_json, headers: headers
      end

      it_behaves_like 'it fails with message', 'No such assessment id'
    end

    context 'malformed JSON payload' do
      before { expect(ApplicantCreationService).not_to receive(:call) }

      context 'missing applicant' do
        before do
          params.delete(:applicant)
          post assessment_applicant_path(assessment.id), params: params.to_json, headers: headers
        end

        it_behaves_like 'it fails with message', 'Missing parameter date_of_birth'
      end

      context 'future date of birth' do
        let(:dob) { 3.days.from_now.to_date }

        before do
          params[:applicant][:date_of_birth] = dob
          post assessment_applicant_path(assessment.id), params: params.to_json, headers: headers
        end

        it_behaves_like 'it fails with message', /Date must be parsable and in the past/
      end

      context 'missing involvement_type' do
        before do
          params[:applicant].delete(:involvement_type)
          post assessment_applicant_path(assessment.id), params: params.to_json, headers: headers
        end

        it_behaves_like 'it fails with message', 'Missing parameter involvement_type'
      end

      context 'invalid involvement type' do
        before do
          params[:applicant][:involvement_type] = 'Witness'
          post assessment_applicant_path(assessment.id), params: params.to_json, headers: headers
        end

        it_behaves_like 'it fails with message', %(Invalid parameter 'involvement_type' value "Witness": Must be one of: <code>applicant</code>.)
      end

      context 'has_partner_opponent not a boolean' do
        before do
          params[:applicant][:has_partner_opponent] = 'yes'
          post assessment_applicant_path(assessment.id), params: params.to_json, headers: headers
        end

        it_behaves_like 'it fails with message',
                        %(Invalid parameter 'has_partner_opponent' value "yes": Must be one of: <code>true</code>, <code>false</code>, <code>1</code>, <code>0</code>.)
      end

      context 'for documentation' do
        it 'fails with a message', :show_in_doc do
          params[:applicant][:receives_qualifying_benefit] = 'yes'
          post assessment_applicant_path(assessment.id), params: params.to_json, headers: headers
          expect(response).to have_http_status(422)
        end
      end
    end
  end
end

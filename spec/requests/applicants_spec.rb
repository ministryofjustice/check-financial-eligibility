require 'rails_helper'

RSpec.describe ApplicantsController, type: :request do
  describe 'POST applicants' do
    let(:assessment) { create :assessment }
    let(:applicant) { 'applicant' }
    let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }
    let(:params) do
      {
        assessment_id: assessment.id,
        applicant: {
          date_of_birth: 20.years.ago.to_date,
          involvement_type: 'Applicant',
          has_parter_opponent: false,
          receives_qualifying_benefit: true
        }
      }
    end

    context 'valid payload' do
      before do
        service = double ApplicantCreationService, success?: true, applicant: applicant
        expect(ApplicantCreationService).to receive(:call).with(params.to_json).and_return(service)
        post assessment_applicant_path(assessment.id), params: params.to_json, headers: headers
      end

      it 'returns success', :show_in_doc do
        expect(response).to have_http_status(:success)
      end

      it 'returns expected response' do
        expect(json[:success]).to eq(true)
        expect(json[:errors]).to be_empty
        expect(json[:objects]).to eq(applicant)
      end
    end

    context 'invalid payload' do

      shared_examples 'it fails with message' do |message|
        it 'returns unprocessable entity' do
          expect(response).to have_http_status(422)
        end

        it 'returns a response with the specified message' do
          expect(json[:success]).to be false
          message.is_a?(Regexp) ? expect_message_match(json, message) : expect_message_equal(json, message)
          expect(json[:object]).to be_nil
        end

        def expect_message_match(json, message)
          expect(json[:errors].first).to match message
        end

        def expect_message_equal(json, message)
          expect(json[:errors].first).to eq message
        end
      end

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

        it_behaves_like 'it fails with message', %[Invalid parameter 'involvement_type' value "Witness": Must be one of: <code>Applicant</code>.]
      end

      context 'has_partner_opponent not a boolean' do
        before do
          params[:applicant][:has_partner_opponent] = 'yes'
          post assessment_applicant_path(assessment.id), params: params.to_json, headers: headers
        end

        it_behaves_like 'it fails with message', %[Invalid parameter 'has_partner_opponent' value "yes": Must be an boolean, for example 'true' or 'false']
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

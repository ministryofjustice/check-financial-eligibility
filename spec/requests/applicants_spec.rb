require 'rails_helper'

RSpec.describe ApplicantsController, type: :request do
  describe 'POST applicants' do
    let(:assessment) { create :assessment }
    let(:applicant) { 'applicant' }
    let(:params) do
      {
        dummy_payload: true,
        assessment_id: '123'
      }.to_json
    end

    context 'valid payload' do
      before do
        service = double ApplicantCreationService, success?: true, applicant: applicant
        expect(ApplicantCreationService).to receive(:call).with(params).and_return(service)
        post assessment_applicant_path(assessment.id), params: params
      end

      it 'returns success' do
        expect(response).to have_http_status(:success)
      end

      it 'returns expected response' do
        expect(json[:success]).to eq(true)
        expect(json[:errors]).to be_empty
        expect(json[:objects]).to eq(applicant)
      end
    end

    context 'invalid payload' do
      before do
        service = double ApplicantCreationService, success?: false, errors: ['xxx']
        expect(ApplicantCreationService).to receive(:call).with(params).and_return(service)
        post assessment_applicant_path(assessment.id), params: params
      end

      it 'returns http unprocessable entity' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error payload' do
        expect(json[:success]).to eq(false)
        expect(json[:objects]).to eq(nil)
        expect(json[:errors]).to match_array(['xxx'])
      end
    end
  end
end

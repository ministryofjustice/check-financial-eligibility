require 'rails_helper'

RSpec.describe ApplicantsController, type: :request do
  describe 'POST applicants' do
    let(:assessment) { create :assessment }
    let(:params) do
      {
        dummy_payload: true,
        assessment_id: '123'
      }
    end

    context 'valid payload' do
      before do
        expect(ApplicantCreationService).to receive(:new).with(params.to_json).and_return(applicant_create_service)
        post assessment_applicants_path(assessment.id), params: params.to_json
      end
      let(:applicant_create_service) { double ApplicantCreationService, success?: true, assessment: assessment }

      it 'returns success' do
        expect(response.status).to eq 200
      end

      it 'returns expected response' do
        expect(response.body).to eq({ status: :ok, assessment_id: assessment.id }.to_json)
      end
    end

    context 'invalid payload' do
      before do
        expect(ApplicantCreationService).to receive(:new).with(params.to_json).and_return(applicant_create_service)
        post assessment_applicants_path(assessment.id), params: params.to_json
      end
      let(:applicant_create_service) { double ApplicantCreationService, success?: false, errors: ['xxx'] }

      it 'returns unprocessable entity' do
        expect(response.status).to eq 422
      end

      it 'returns expected response' do
        expect(response.body).to eq({ status: :error, errors: ['xxx'] }.to_json)
      end
    end
  end
end

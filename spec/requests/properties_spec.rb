require 'rails_helper'

RSpec.describe PropertiesController, type: :request do
  describe 'POST properties' do
    let(:assessment) { create :assessment }
    let(:property) { create :property, assessment: assessment }
    let(:dummy_payload) { { key: :value }.to_json }
    let(:properties_creation_service) { double PropertiesCreationService, success?: true, properties: [property] }

    context 'valid params' do
      before do
        expect(PropertiesCreationService).to receive(:call).with(dummy_payload).and_return(properties_creation_service)
        post assessment_properties_path(assessment), params: dummy_payload
      end

      it 'returns http status code 200' do
        expect(response).to have_http_status(:success)
      end

      it 'returns the expected success response payload' do
        expect(response.body).to eq success_response.to_h.to_json
      end
    end

    context 'invalid params' do
      before do
        expect(PropertiesCreationService).to receive(:call).with(dummy_payload).and_return(error_response)
        post assessment_properties_path(assessment), params: dummy_payload
      end

      it 'returns http status code 422' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns the expected error response payload' do
        expect(response.body).to eq error_response.to_h.to_json
      end
    end
  end

  def success_response
    OpenStruct.new(
      success: true,
      objects: [property],
      errors: []
    )
  end

  def error_response
    OpenStruct.new(
      success: false,
      objects: nil,
      errors: ['an error message']
    )
  end
end

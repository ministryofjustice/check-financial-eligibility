require 'rails_helper'

RSpec.describe VehiclesController, type: :request do
  let(:assessment) { create :assessment }
  let(:vehicle_1) { create :vehicle, assessment: assessment }
  let(:vehicle_2) { create :vehicle, assessment: assessment }

  let(:dummy_payload) do
    {
      assessment_id: assessment.id,
      vehicles: []
    }.to_json
  end

  let(:success_service_result) do
    OpenStruct.new(
      success: true,
      vehicles: [vehicle_1, vehicle_2],
      errors: []
    )
  end

  let(:error_service_result) do
    OpenStruct.new(
      success: false,
      vehicles: nil,
      errors: [
        'first error',
        'second error'
      ]
    )
  end

  describe 'POST assessments/:id/vehicles' do
    context 'valid payload' do
      before do
        service = double(VehicleCreationService, call: success_service_result)
        expect(VehicleCreationService).to receive(:new).with(dummy_payload).and_return(service)
        post assessment_vehicles_path(assessment), params: dummy_payload
      end

      it 'returns https status 200' do
        expect(response).to have_http_status(:success)
      end

      it 'serializes the response' do
        expect(response.body).to eq successful_response
      end
    end

    context 'invalid_payload' do
      before do
        service = double(VehicleCreationService, call: error_service_result)
        expect(VehicleCreationService).to receive(:new).with(dummy_payload).and_return(service)
        post assessment_vehicles_path(assessment), params: dummy_payload
      end

      it 'returns https status 422' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'serializes the response' do
        expect(response.body).to eq error_service_result.to_h.to_json
      end
    end
  end

  def successful_response
    {
      success: true,
      vehicles: [vehicle_1, vehicle_2],
      errors: []
    }.to_json
  end
end

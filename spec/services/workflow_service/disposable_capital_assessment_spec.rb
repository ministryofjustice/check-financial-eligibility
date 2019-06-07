require 'rails_helper'

module WorkflowService
  RSpec.describe DisposableCapitalAssessment do
    let(:service) { DisposableCapitalAssessment.new(particulars) }
    let(:request_hash) { AssessmentRequestFixture.ruby_hash }
    let(:assessment) { create :assessment, request_payload: request_hash.to_json }
    let(:particulars) { AssessmentParticulars.new(assessment) }
    let(:today) { Date.new(2019, 4, 2) }

    describe '#call' do
      it 'always returns true' do
        expect(service.call).to be true
      end

      context 'liquid capital' do
        it 'instantiates and calls the Liquid Capital Assessment service' do
          lcas = double LiquidCapitalAssessment
          expect(LiquidCapitalAssessment).to receive(:new)
            .with(particulars.request.applicant_capital.liquid_capital)
            .and_return(lcas)
          expect(lcas).to receive(:call).and_return(156.26)
          expect(particulars.response.details.capital).to receive(:liquid_capital_assessment=).with(156.26)
          service.call
        end
      end

      context 'property_assessment' do
        it 'instantiates and calls the Property Assessment service' do
          property_service = double PropertyAssessment
          property_details = particulars.request.applicant_capital.property
          expect(PropertyAssessment).to receive(:new).with(property_details, today).and_return(property_service)
          expect(property_service).to receive(:call).and_return(property_assessment_result)
          service.call
          expect(particulars.response.details.capital.property).to eq property_assessment_result
        end
      end

      context 'vehicle assessment' do
        it 'instantiates and calls the Vehicle Assesment service' do
          vehicle_service = double VehicleAssessment
          vehicle_details = particulars.request.applicant_capital.vehicles
          expect(VehicleAssessment).to receive(:new).with(vehicle_details, today).and_return(vehicle_service)
          expect(vehicle_service).to receive(:call).and_return('Vehicle Result')
          service.call
          expect(particulars.response.details.capital.vehicles).to eq 'Vehicle Result'
        end
      end

      context 'non_liquid_capital_assessment' do
        it 'instantiates and calls NonLiquidCapitalAssessment' do
          nlcas = double NonLiquidCapitalAssessment
          expect(NonLiquidCapitalAssessment).to receive(:new)
            .with(particulars.request.applicant_capital.non_liquid_capital)
            .and_return(nlcas)
          expect(nlcas).to receive(:call).and_return(26_733.77)
          expect(particulars.response.details.capital).to receive(:non_liquid_capital_assessment=).with(26_733.77)
          service.call
        end
      end
    end

    def property_assessment_result
      @property_assessment_result ||= JSON.parse(AssessmentResponseFixture.ruby_hash[:details][:capital][:property].to_json, object_class: DatedStruct)
    end
  end
end

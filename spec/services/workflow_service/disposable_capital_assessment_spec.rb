require 'rails_helper'

module WorkflowService # rubocop:disable Metrics/ModuleLength
  RSpec.describe DisposableCapitalAssessment do
    let(:service) { DisposableCapitalAssessment.new(particulars) }
    let(:request_hash) { AssessmentRequestFixture.ruby_hash }
    let(:assessment) { create :assessment, request_payload: request_hash.to_json }
    let(:particulars) { AssessmentParticulars.new(assessment) }

    describe '#call' do
      it 'always returns true' do
        expect(service.call).to be true
      end

      context 'liquid capital' do
        it 'instantiates and calls the Property Assessment service' do
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
          expect(PropertyAssessment).to receive(:new).with(particulars).and_return(property_service)
          expect(property_service).to receive(:call).and_return(true)
          service.call
        end
      end

      context 'vehicle assessment' do
        it 'instantiates and calles the Vehicle Assesment service' do
          vehicle_service = double VehicleAssessment
          expect(VehicleAssessment).to receive(:new).with(particulars).and_return(vehicle_service)
          expect(vehicle_service).to receive(:call).and_return(true)
          service.call
        end
      end
    end

    def main_dwelling_big_mortgage_wholly_owned
      {
        main_home: {
          value: 466_993,
          outstanding_mortgage: 266_000,
          percentage_owned: 100.0,
          shared_with_housing_assoc: false
        },
        additional_properties: []
      }
    end

    def main_dwelling_small_mortgage_wholly_owned
      {
        main_home: {
          value: 466_993,
          outstanding_mortgage: 37_256.44,
          percentage_owned: 100.0,
          shared_with_housing_assoc: false
        },
        additional_properties: []
      }
    end

    def main_dwelling_big_mortgage_partly_owned
      {
        main_home: {
          value: 466_993,
          outstanding_mortgage: 266_000,
          percentage_owned: 66.66,
          shared_with_housing_assoc: false
        },
        additional_properties: []
      }
    end

    def main_dwelling_small_mortgage_partly_owned
      {
        main_home: {
          value: 466_993,
          outstanding_mortgage: 37_256.44,
          percentage_owned: 66.66,
          shared_with_housing_assoc: false
        },
        additional_properties: []
      }
    end

    def main_dwelling_shared_with_housing_association
      {
        main_home: {
          value: 160_000,
          outstanding_mortgage: 70_000,
          percentage_owned: 50.0,
          shared_with_housing_assoc: true
        },
        additional_properties: []
      }
    end

    def main_dwelling_and_addtional_properties_wholly_owned
      {
        main_home: {
          value: 220_000,
          outstanding_mortgage: 35_000,
          percentage_owned: 100.0,
          shared_with_housing_assoc: false
        },
        additional_properties: [
          {
            value: 350_000,
            outstanding_mortgage: 55_000,
            percentage_owned: 100,
            shared_with_housing_assoc: false
          },
          {
            value: 270_000,
            outstanding_mortgage: 40_000,
            percentage_owned: 100,
            shared_with_housing_assoc: false
          }
        ]
      }
    end
  end
end

require 'rails_helper'

module WorkflowService # rubocop:disable Metrics/ModuleLength
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

      context 'pensioner disregard' do
        it 'instantiates and calls the PensionerCapitalDisregard service' do
          pcd = double PensionerCapitalDisregard
          expect(PensionerCapitalDisregard)
            .to receive(:new)
            .with(particulars)
            .and_return(pcd)
          expect(pcd).to receive(:value).and_return(20_000.0)
          service.call
          expect(particulars.response.details.capital.pensioner_disregard).to eq 20_000
        end
      end

      context 'population of result_fields' do
        it 'populates the result fields with the results of the calculation' do
          service.call
          capital = particulars.response.details.capital
          expect(capital.single_capital_assessment).to eq 700_828.87
          expect(capital.pensioner_disregard).to eq 100_000
          expect(capital.disposable_capital_assessment).to eq 600_828.87
          expect(capital.total_capital_lower_threshold).to eq 3_000
          expect(capital.total_capital_upper_threshold).to eq 8_000
        end
      end
    end

    def property_assessment_result
      @property_assessment_result ||= JSON.parse(AssessmentResponseFixture.ruby_hash[:details][:capital][:property].to_json,
                                                 object_class: DatedStruct)
    end

    def expected_property_result
      open_structify(
        main_home: {
          notional_sale_costs_pctg: 3.0,
          net_value_after_deduction: 452_925.01,
          maximum_mortgage_allowance: 0,
          net_value_after_mortgage: 452_925.01,
          percentage_owned: 50,
          net_equity_value: 226_462.51,
          property_disregard: 100_000,
          assessed_capital_value: 0
        },
        additional_properties: [
          {
            notional_sale_costs_pctg: 3.0,
            net_value_after_deduction: 452_925.01,
            maximum_mortgage_allowance: 100_000,
            net_value_after_mortgage: 352_925.01,
            percentage_owned: 100,
            net_equity_value: 352_925.01,
            property_disregard: 0.0,
            assessed_capital_value: 352_925.01
          },
          {
            notional_sale_costs_pctg: 3.0,
            net_value_after_deduction: 452_925.01,
            maximum_mortgage_allowance: 0,
            net_value_after_mortgage: 452_925.01,
            percentage_owned: 33.33,
            net_equity_value: 150_959.91,
            property_disregard: 0.0,
            assessed_capital_value: 150_959.91
          }
        ]
      )
    end

    def expected_vehicle_result
      open_structify(
        [
          {
            value: 9_500,
            loan_amount_outstanding: 6_000,
            date_of_purchase: Date.new(2015, 8, 13),
            in_regular_use: true,
            assessed_value: 0
          }
        ]
      )
    end
  end
end

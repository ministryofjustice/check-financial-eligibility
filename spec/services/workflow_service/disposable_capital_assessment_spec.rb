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
        context 'all positive supplied' do
          it 'adds them all together' do
            particulars.request.applicant_capital.liquid_capital.bank_accounts = open_structify(all_positive_bank_accounts)
            expect(service.call).to be true
            expect(particulars.response.details.liquid_capital_assessment).to eq 136.87
          end
        end

        context 'mixture of positive and negative supplied' do
          it 'ignores negative values' do
            particulars.request.applicant_capital.liquid_capital.bank_accounts = open_structify(mixture_of_negative_and_positive_bank_accounts)
            expect(service.call).to be true
            expect(particulars.response.details.liquid_capital_assessment).to eq 35.88
          end
        end

        context 'all negative supplied' do
          it 'ignores negative values' do
            particulars.request.applicant_capital.liquid_capital.bank_accounts = open_structify(all_negative_bank_accounts)
            expect(service.call).to be true
            expect(particulars.response.details.liquid_capital_assessment).to eq 0.0
          end
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

    def all_positive_bank_accounts
      [
        { account_name: 'Account 1', lowest_balance: 35.66 },
        { account_name: 'Account 2', lowest_balance: 100.99 },
        { account_name: 'Account 3', lowest_balance: 0.22 }
      ]
    end

    def mixture_of_negative_and_positive_bank_accounts
      [
        { account_name: 'Account 1', lowest_balance: 35.66 },
        { account_name: 'Account 2', lowest_balance: - 100.99 },
        { account_name: 'Account 3', lowest_balance: 0.22 }
      ]
    end

    def all_negative_bank_accounts
      [
        { account_name: 'Account 1', lowest_balance: -35.66 },
        { account_name: 'Account 2', lowest_balance: - 100.99 },
        { account_name: 'Account 3', lowest_balance: -0.22 }
      ]
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

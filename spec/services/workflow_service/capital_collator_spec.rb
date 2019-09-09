require 'rails_helper'

module WorkflowService
  RSpec.describe CapitalCollator do
    let(:assessment) { create :assessment, :with_applicant }
    let(:request_hash) { AssessmentRequestFixture.ruby_hash }
    let(:submission_date) { assessment.submission_date }
    let(:capital_summary) { assessment.capital_summary }
    let(:today) { Date.new(2019, 4, 2) }

    describe '.call' do
      subject { described_class.call assessment }

      it 'always returns a hash' do
        expect(subject).to be_a Hash
      end

      context 'liquid capital' do
        it 'calls LiquidCapitalAssessment and updates capital summary with the result' do
          liquid_capital_service = double LiquidCapitalAssessment
          expect(LiquidCapitalAssessment).to receive(:new).with(assessment).and_return(liquid_capital_service)
          expect(liquid_capital_service).to receive(:call).and_return(145.83)
          expect(subject[:total_liquid]).to eq 145.83
        end
      end

      context 'property_assessment' do
        it 'instantiates and calls the Property Assessment service' do
          property_service = double PropertyAssessment
          expect(PropertyAssessment).to receive(:new).and_return(property_service)
          expect(property_service).to receive(:call).and_return(23_000.0)
          subject
          expect(subject[:total_property]).to eq 23_000.0
        end
      end

      context 'vehicle assessment' do
        it 'instantiates and calls the Vehicle Assesment service' do
          vehicle_service = double VehicleAssessment
          expect(VehicleAssessment).to receive(:new).with(assessment).and_return(vehicle_service)
          expect(vehicle_service).to receive(:call).and_return(2_500.0)
          subject
          expect(subject[:total_vehicle]).to eq 2_500.0
        end
      end

      context 'non_liquid_capital_assessment' do
        it 'instantiates and calls NonLiquidCapitalAssessment' do
          nlcas = double NonLiquidCapitalAssessment
          expect(NonLiquidCapitalAssessment).to receive(:new).with(assessment).and_return(nlcas)
          expect(nlcas).to receive(:call).and_return(500)
          subject
          expect(subject[:total_non_liquid]).to eq 500.0
        end
      end

      context 'pensioner disregard' do
        it 'instantiates and calls the PensionerCapitalDisregard service' do
          pcd = double PensionerCapitalDisregard
          expect(PensionerCapitalDisregard).to receive(:new).with(assessment).and_return(pcd)
          expect(pcd).to receive(:value).and_return(100_000)
          subject
          expect(subject[:pensioner_capital_disregard]).to eq 100_000
        end
      end

      context 'summarization of result_fields' do
        it 'summarizes the results it gets from the subservices' do
          liquid_capital_service = double LiquidCapitalAssessment
          nlcas = double NonLiquidCapitalAssessment
          vehicle_service = double VehicleAssessment
          property_service = double PropertyAssessment
          pcd = double PensionerCapitalDisregard

          expect(LiquidCapitalAssessment).to receive(:new).with(assessment).and_return(liquid_capital_service)
          expect(NonLiquidCapitalAssessment).to receive(:new).with(assessment).and_return(nlcas)
          expect(VehicleAssessment).to receive(:new).with(assessment).and_return(vehicle_service)
          expect(PropertyAssessment).to receive(:new).and_return(property_service)
          expect(PensionerCapitalDisregard).to receive(:new).and_return(pcd)

          expect(liquid_capital_service).to receive(:call).and_return(145.83)
          expect(nlcas).to receive(:call).and_return(500)
          expect(vehicle_service).to receive(:call).and_return(2_500.0)
          expect(property_service).to receive(:call).and_return(23_000.0)
          expect(pcd).to receive(:value).and_return(100_000)

          subject
          expect(subject[:total_liquid]).to eq 145.83
          expect(subject[:total_non_liquid]).to eq 500
          expect(subject[:total_vehicle]).to eq 2_500
          expect(subject[:total_property]).to eq 23_000
          expect(subject[:total_mortgage_allowance]).to eq 100_000
          expect(subject[:total_capital]).to eq 26_145.83
          expect(subject[:pensioner_capital_disregard]).to eq 100_000
          expect(subject[:assessed_capital]).to eq(-73_854.17)
          expect(subject[:lower_threshold]).to eq 3_000
          expect(subject[:upper_threshold]).to eq 8_000
        end
      end
    end
  end
end

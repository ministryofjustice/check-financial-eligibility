require 'rails_helper'

module WorkflowService # rubocop:disable Metrics/ModuleLength
  RSpec.describe VehicleAssessment do
    let(:assessment) { create :assessment }
    let(:service) { described_class.new(assessment) }

    describe '#call' do
      context 'vehicle in use' do
        context 'valued less than threshold' do
          let(:vehicle) { create :vehicle, value: 9_500, loan_amount_outstanding: 0, date_of_purchase: 26.months.ago.to_date, in_regular_use: true }
          it 'is assessed at zero' do
            assessment.vehicles << vehicle
            result = service.call
            expect(result.first).to have_matching_attributes(vehicle, common_attributes)
            expect(result.first.assessed_value).to eq 0.0
          end
        end

        context 'valued at more than threshold' do
          context 'more than 3 years old' do
            let(:vehicle) { create :vehicle, value: 18_700, loan_amount_outstanding: 0, date_of_purchase: 38.months.ago.to_date, in_regular_use: true }
            it 'is assessed at zero' do
              assessment.vehicles << vehicle
              result = service.call
              expect(result.first).to have_matching_attributes(vehicle, common_attributes)
              expect(result.first.assessed_value).to eq 0.0
            end
          end

          context 'less than 1 year old' do
            context 'with an outstanding loan' do
              let(:vehicle) { create :vehicle, value: 23_700, loan_amount_outstanding: 2_250, date_of_purchase: 5.months.ago.to_date, in_regular_use: true }
              it 'is assessed at value less loan less threshold' do
                assessment.vehicles << vehicle
                result = service.call
                expect(result.first).to have_matching_attributes(vehicle, common_attributes)
                expect(result.first.assessed_value).to eq 6_450.0
              end
            end

            context 'without an outstanding loan' do
              let(:vehicle) { create :vehicle, value: 23_700, loan_amount_outstanding: 0, date_of_purchase: 5.months.ago.to_date, in_regular_use: true }
              it 'is assessed at value less threshold' do
                assessment.vehicles << vehicle
                result = service.call
                expect(result.first).to have_matching_attributes(vehicle, common_attributes)
                expect(result.first.assessed_value).to eq 8_700.0
              end
            end
          end

          context 'more than 1 year less than 2 years old' do
            context 'with an outstanding loan' do
              let(:vehicle) { create :vehicle, value: 23_700, loan_amount_outstanding: 2_250, date_of_purchase: 15.months.ago.to_date, in_regular_use: true }
              it 'is assessed at 80% of value less outstanding loan' do
                assessment.vehicles << vehicle
                result = service.call
                expect(result.first).to have_matching_attributes(vehicle, common_attributes)
                expect(result.first.assessed_value).to eq 2_160.0
              end
            end

            context 'without an oustanding loan' do
              let(:vehicle) { create :vehicle, value: 23_700, loan_amount_outstanding: 0, date_of_purchase: 15.months.ago.to_date, in_regular_use: true }
              it 'is assesssed at 80% of value' do
                assessment.vehicles << vehicle
                result = service.call
                expect(result.first).to have_matching_attributes(vehicle, common_attributes)
                expect(result.first.assessed_value).to eq 3_960.0
              end
            end
          end

          context 'more than 2 years less than 3 years old' do
            context 'with an outstanding loan' do
              let(:vehicle) { create :vehicle, value: 23_700, loan_amount_outstanding: 2_250, date_of_purchase: 26.months.ago.to_date, in_regular_use: true }
              it 'is assessed at 60% of value less outstanding loan' do
                assessment.vehicles << vehicle
                result = service.call
                expect(result.first).to have_matching_attributes(vehicle, common_attributes)
                expect(result.first.assessed_value).to eq 0.0
              end
            end
          end
        end
      end

      context 'vehicle not in regular use' do
        let(:vehicle) { create :vehicle, value: 23_700, loan_amount_outstanding: 2_250, date_of_purchase: 26.months.ago.to_date, in_regular_use: false }
        it 'is assessed at full value' do
          assessment.vehicles << vehicle
          result = service.call
          expect(result.first).to have_matching_attributes(vehicle, common_attributes)
          expect(result.first.assessed_value).to eq 23_700.0
        end
      end

      context 'multiple vehicles' do
        context 'multiple vehicles included not in capital assessment' do
          let(:vehicle_1) { create :vehicle, value: 9_500, loan_amount_outstanding: 0, date_of_purchase: 26.months.ago.to_date, in_regular_use: true }
          let(:vehicle_2) { create :vehicle, value: 15_500, loan_amount_outstanding: 0, date_of_purchase: 46.months.ago.to_date, in_regular_use: true }
          it 'is assessed at zero' do
            assessment.vehicles << vehicle_1
            assessment.vehicles << vehicle_2
            result = service.call
            expect(result.first).to have_matching_attributes(vehicle_1, common_attributes)
            expect(result.first.assessed_value).to eq 0.0
            expect(result[1]).to have_matching_attributes(vehicle_2, common_attributes)
            expect(result[1].assessed_value).to eq 0.0
          end
        end

        context 'multiple vehicles included in capital assessment' do
          let(:vehicle_1) { create :vehicle, value: 23_700, loan_amount_outstanding: 2_250, date_of_purchase: 15.months.ago.to_date, in_regular_use: true }
          let(:vehicle_2) { create :vehicle, value: 23_700, loan_amount_outstanding: 2_250, date_of_purchase: 26.months.ago.to_date, in_regular_use: false }
          it 'is assessed at zero' do
            assessment.vehicles << vehicle_1
            assessment.vehicles << vehicle_2
            result = service.call
            expect(result.first).to have_matching_attributes(vehicle_1, common_attributes)
            expect(result.first.assessed_value).to eq 2_160.0
            expect(result[1]).to have_matching_attributes(vehicle_2, common_attributes)
            expect(result[1].assessed_value).to eq 23_700.0
          end
        end

        context 'mix of vehicles included/not included in capital assessment' do
          let(:vehicle_1) { create :vehicle, value: 9_500, loan_amount_outstanding: 0, date_of_purchase: 26.months.ago.to_date, in_regular_use: true }
          let(:vehicle_2) { create :vehicle, value: 23_700, loan_amount_outstanding: 2_250, date_of_purchase: 26.months.ago.to_date, in_regular_use: false }
          it 'is assessed at zero' do
            assessment.vehicles << vehicle_1
            assessment.vehicles << vehicle_2
            result = service.call
            expect(result.first).to have_matching_attributes(vehicle_1, common_attributes)
            expect(result.first.assessed_value).to eq 0.0
            expect(result[1]).to have_matching_attributes(vehicle_2, common_attributes)
            expect(result[1].assessed_value).to eq 23_700.0
          end
        end
      end

      def common_attributes
        %i[value loan_amount_outstanding date_of_purchase in_regular_use]
      end
    end
  end
end

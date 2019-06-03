require 'rails_helper'

module WorkflowService # rubocop:disable Metrics/ModuleLength
  RSpec.describe VehicleAssessment do
    let(:service) { VehicleAssessment.new(particulars) }
    let(:request_hash) { AssessmentRequestFixture.ruby_hash }
    let(:assessment) { create :assessment, request_payload: request_hash.to_json }
    let(:particulars) { AssessmentParticulars.new(assessment) }

    describe '#call' do
      it 'always returns true' do
        expect(service.call).to be true
      end

      context 'vehicle in use' do
        context 'valued less than threshold' do
          it 'is assessed at zero' do
            request_detail = open_structify(in_use_less_than_threshold)
            particulars.request.applicant_capital.liquid_capital.vehicles = request_detail
            expect(service.call).to be true
            result = particulars.response.details.capital.vehicles.first

            expect(result).to have_matching_attributes(request_detail.first, common_attributes)
            expect(result.assessed_value).to eq 0.0
          end
        end

        context 'valued at more than threshold' do
          context 'more than 3 years old' do
            it 'is assessed at zero' do
              request_detail = open_structify(in_use_more_than_three_yeas_old)
              particulars.request.applicant_capital.liquid_capital.vehicles = request_detail
              expect(service.call).to be true
              result = particulars.response.details.capital.vehicles.first

              expect(result).to have_matching_attributes(request_detail.first, common_attributes)
              expect(result.assessed_value).to eq 0.0
            end
          end

          context 'less than 1 year old' do
            context 'with an outstanding loan' do
              it 'is assessed at value less loan less threshold' do
                request_detail = open_structify(in_use_less_than_1_year)
                particulars.request.applicant_capital.liquid_capital.vehicles = request_detail
                expect(service.call).to be true
                result = particulars.response.details.capital.vehicles.first

                expect(result).to have_matching_attributes(request_detail.first, common_attributes)
                expect(result.assessed_value).to eq 6_450.0
              end
            end

            context 'without an outstanding loan' do
              it 'is assessed at value less threshold' do
                request_detail = open_structify(in_use_less_than_1_year_no_loan)
                particulars.request.applicant_capital.liquid_capital.vehicles = request_detail
                expect(service.call).to be true
                result = particulars.response.details.capital.vehicles.first

                expect(result).to have_matching_attributes(request_detail.first, common_attributes)
                expect(result.assessed_value).to eq 8_700.0
              end
            end
          end

          context 'more than 1 year less than 2 years old' do
            context 'with an outstanding loan' do
              it 'is assessed at 80% of value less outstanding loan' do
                request_detail = open_structify(in_use_15_months)
                particulars.request.applicant_capital.liquid_capital.vehicles = request_detail
                expect(service.call).to be true
                result = particulars.response.details.capital.vehicles.first

                expect(result).to have_matching_attributes(request_detail.first, common_attributes)
                expect(result.assessed_value).to eq 2_160.0
              end
            end

            context 'without an oustanding loan' do
              it 'is assesssed at 80% of value' do
                request_detail = open_structify(in_use_15_months_no_loan)
                particulars.request.applicant_capital.liquid_capital.vehicles = request_detail
                expect(service.call).to be true
                result = particulars.response.details.capital.vehicles.first

                expect(result).to have_matching_attributes(request_detail.first, common_attributes)
                expect(result.assessed_value).to eq 3_960.0
              end
            end
          end

          context 'more than 2 years less than 3 years old' do
            context 'with an outstanding loan' do
              it 'is assessed at 60% of value less outstanding loan' do
                request_detail = open_structify(in_use_26_months)
                particulars.request.applicant_capital.liquid_capital.vehicles = request_detail
                expect(service.call).to be true
                result = particulars.response.details.capital.vehicles.first

                expect(result).to have_matching_attributes(request_detail.first, common_attributes)
                expect(result.assessed_value).to eq 0.0
              end
            end
          end
        end
      end

      context 'vehicle not in regular use' do
        it 'is assessed at full value' do
          request_detail = open_structify(not_in_regular_use)
          particulars.request.applicant_capital.liquid_capital.vehicles = request_detail
          expect(service.call).to be true
          result = particulars.response.details.capital.vehicles.first

          expect(result).to have_matching_attributes(request_detail.first, common_attributes)
          expect(result.assessed_value).to eq 23_700.00
        end
      end

      context 'multiple vehicles' do
      end

      def common_attributes
        %i[value load_amount_outstanding date_of_purchase in_regular_user]
      end

      def in_use_less_than_threshold
        [
          {
            value: 9_500,
            loan_amount_outstanding: 0,
            date_of_purchase: 26.months.ago.to_date,
            in_regular_use: true
          }
        ]
      end

      def in_use_more_than_three_yeas_old
        [
          {
            value: 18_700,
            loan_amount_outstanding: 0,
            date_of_purchase: 38.months.ago.to_date,
            in_regular_use: true
          }
        ]
      end

      def in_use_less_than_1_year
        # value should be (100% of 23,700) - 2,250 - 15,000 = 6,450
        [
          {
            value: 23_700,
            loan_amount_outstanding: 2_250,
            date_of_purchase: 5.months.ago.to_date,
            in_regular_use: true
          }
        ]
      end

      def in_use_less_than_1_year_no_loan
        # value should be (100% of 23,700) - 0 - 15,000 = 8,700
        [
          {
            value: 23_700,
            loan_amount_outstanding: 0,
            date_of_purchase: 5.months.ago.to_date,
            in_regular_use: true
          }
        ]
      end

      def in_use_15_months
        # value should be (80% of 23,700) - 2,250 - 15,000 = 8,700
        [
          {
            value: 23_700,
            loan_amount_outstanding: 2_250,
            date_of_purchase: 15.months.ago.to_date,
            in_regular_use: true
          }
        ]
      end

      def in_use_15_months_no_loan
        # value should be (80% of 23,700) - 0 - 15,000 = 3,960
        [
          {
            value: 23_700,
            loan_amount_outstanding: 0,
            date_of_purchase: 15.months.ago.to_date,
            in_regular_use: true
          }
        ]
      end

      def in_use_26_months
        # value should be (60% of 23,700) - 2,250 - 15,000 = -2130.00, i.e. zero
        [
          {
            value: 23_700,
            loan_amount_outstanding: 2_250,
            date_of_purchase: 26.months.ago.to_date,
            in_regular_use: true
          }
        ]
      end

      def not_in_regular_use
        # value should be full value of car
        [
          {
            value: 23_700,
            loan_amount_outstanding: 2_250,
            date_of_purchase: 26.months.ago.to_date,
            in_regular_use: false
          }
        ]
      end
    end
  end
end

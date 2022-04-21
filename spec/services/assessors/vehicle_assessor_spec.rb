require "rails_helper"

module Assessors
  RSpec.describe VehicleAssessor do
    let(:assessment) { create :assessment, :with_capital_summary }
    let(:capital_summary) { assessment.capital_summary }
    let(:service) { described_class.new(assessment) }
    let!(:vehicle) do
      create :vehicle,
             capital_summary:,
             value: estimated_value,
             loan_amount_outstanding:,
             date_of_purchase:,
             in_regular_use:
    end

    before do
      service.call
      vehicle.reload
    end

    describe "#call" do
      context "vehicle in use" do
        let(:in_regular_use) { true }

        context "estimated value less than threshold" do
          let(:estimated_value) { 14_900 }

          context "purchased less than 36 months ago" do
            let(:date_of_purchase) { 35.months.ago.to_date }
            let(:loan_amount_outstanding) { 0.0 }

            it "is not included in the assessment" do
              expect(vehicle.included_in_assessment).to be false
              expect(vehicle.assessed_value).to eq 0.0
            end
          end

          context "purchased more than 36 months ago" do
            let(:date_of_purchase) { 37.months.ago.to_date }
            let(:loan_amount_outstanding) { 0.0 }

            it "is not included in the assessment" do
              expect(vehicle.included_in_assessment).to be false
              expect(vehicle.assessed_value).to eq 0.0
            end
          end
        end

        context "estimated value more than threshold" do
          let(:estimated_value)  { 21_000.0 }

          context "net value after deducting loan less than threshold" do
            let(:loan_amount_outstanding) { 7_000 }

            context "purchased more than 36 moths ago" do
              let(:date_of_purchase) { 37.months.ago.to_date }

              it "is not included in the assessment" do
                expect(vehicle.included_in_assessment).to be false
                expect(vehicle.assessed_value).to eq 0.0
              end
            end

            context "purchased less than 36 months ago" do
              let(:date_of_purchase) { 3.months.ago.to_date }

              it "is not included in the assessment" do
                expect(vehicle.included_in_assessment).to be false
                expect(vehicle.assessed_value).to eq 0.0
              end
            end
          end

          context "net value after deducting loan more than threshold" do
            let(:loan_amount_outstanding) { 2_000.0 }

            context "purchased more than 36 months ago" do
              let(:date_of_purchase) { 40.months.ago.to_date }

              it "is not included in the assessment" do
                expect(vehicle.included_in_assessment).to be false
                expect(vehicle.assessed_value).to eq 0.0
              end
            end

            context "purchased less than 36 months ago" do
              let(:date_of_purchase) { 10.months.ago.to_date }

              it "is assessed at estimated value - loan amount outstanding - 15,000" do
                expect(vehicle.included_in_assessment).to be true
                expect(vehicle.assessed_value).to eq 4_000.0
              end
            end
          end
        end
      end

      context "vehicle not in regular use" do
        let(:in_regular_use) { false }
        let(:estimated_value)  { 18_450.0 }

        context "vehicle purchased less than 36 months ago" do
          let(:date_of_purchase) { 26.months.ago.to_date }

          context "net equity greater than threshold" do
            let(:loan_amount_outstanding) { 1_000.0 }

            it "is assessed at the estimated value" do
              expect(vehicle.included_in_assessment).to be true
              expect(vehicle.assessed_value).to eq 18_450.0
            end
          end

          context "net equity less than threshold" do
            let(:loan_amount_outstanding) { 12_000 }

            it "is assessed at the estimated value" do
              expect(vehicle.included_in_assessment).to be true
              expect(vehicle.assessed_value).to eq 18_450.0
            end
          end
        end

        context "vehicle purchased more than 36 months ago" do
          let(:date_of_purchase) { 40.months.ago.to_date }

          context "net equity greater than threshold" do
            let(:loan_amount_outstanding) { 0.0 }

            it "is assessed at the estimated value" do
              expect(vehicle.included_in_assessment).to be true
              expect(vehicle.assessed_value).to eq 18_450.0
            end
          end

          context "net equity less than threshold" do
            let(:loan_amount_outstanding) { 10_900.0 }

            it "is assessed at the estimated value" do
              expect(vehicle.included_in_assessment).to be true
              expect(vehicle.assessed_value).to eq 18_450.0
            end
          end
        end
      end
    end
  end
end

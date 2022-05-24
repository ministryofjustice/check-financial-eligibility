require "rails_helper"

module Utilities
  RSpec.describe EmploymentIncomeMonthlyEquivalentCalculator, :vcr do
    let(:assessment) { create :assessment }
    let(:employment) { create :employment, assessment: }
    let(:payments) { employment.employment_payments }

    context "valid payment period" do
      before do
        create_employment_payment_records
        described_class.call(employment)
      end

      context "monthly payment" do
        let(:dates) { %w[2022-01-31 2022-02-28 2022-03-31] }

        context "non varying amounts" do
          let(:amounts) { [2456.83, 2456.83, 2456.83] }

          it "populates monthly equivalent field with gross income" do
            expect(payments.map(&:gross_income_monthly_equiv)).to eq amounts
          end
        end

        context "amounts varying < £60" do
          let(:amounts) { [2456.83, 2412.66, 2447.33] }

          it "populates monthly equivalent field with gross income" do
            payments.each do |payment|
              expect(payment.gross_income_monthly_equiv).to eq payment.gross_income
            end
          end
        end
      end

      context "four-weekly payment" do
        let(:dates) { %w[2022-01-14 2022-02-11 2022-03-11] }

        context "non varying amounts" do
          let(:amounts) { [2456.83, 2456.83, 2456.83] }

          it "populates monthly equivalent field with gross income" do
            expect(payments.map(&:gross_income_monthly_equiv).uniq).to eq [2661.57]
          end
        end

        context "varying amounts" do
          let(:amounts) { [2456.83, 2412.66, 2447.33] }

          it "populates the gross income monthly equiv with calculated amount" do
            expect(payments.find_by(date: Date.parse("2022-01-14")).gross_income_monthly_equiv).to eq 2661.57
            expect(payments.find_by(date: Date.parse("2022-02-11")).gross_income_monthly_equiv).to eq 2613.72
            expect(payments.find_by(date: Date.parse("2022-03-11")).gross_income_monthly_equiv).to eq 2651.27
          end
        end
      end

      context "two-weekly payments" do
        let(:dates) { %w[2022-01-14 2022-01-28 2022-02-11 2022-02-25 2022-03-11 2022-03-25] }

        context "non varying amounts" do
          let(:amounts) { [1000.0, 1000.0, 1000.0, 1000.0, 1000.0, 1000.0] }

          it "populates monthly equivalent field with gross income" do
            expect(payments.map(&:gross_income_monthly_equiv).uniq).to eq [2166.67]
          end
        end
      end

      context "weekly payments" do
        let(:dates) { %w[2022-01-07 2022-01-14 2022-01-21 2022-01-28 2022-02-04 2022-02-11 2022-02-18 2022-02-25 2022-03-04 2022-03-11 2022-03-18 2022-03-25] }

        context "non varying amounts" do
          let(:amounts) { [1000.0, 1000.0, 1000.0, 1000.0, 1000.0, 1000.0, 1000.0, 1000.0, 1000.0, 1000.0, 1000.0, 1000.0] }

          it "populates monthly equivalent field with gross income" do
            expect(payments.map(&:gross_income_monthly_equiv).uniq).to eq [4333.33]
          end
        end
      end

      context "blunt average" do
        let(:dates) { %w[2021-12-10 2021-11-12 2021-10-15 2021-09-17 2021-08-20 2021-07-15] }

        context "varying amounts" do
          let(:amounts) { [100, 100, 100, 100, 100, 100] }

          it "populates monthly equivalent field with gross income" do
            expect(payments.map(&:gross_income_monthly_equiv).uniq).to eq [100]
          end
        end
      end

      def create_employment_payment_records
        dates.each_with_index do |date_string, i|
          create :employment_payment, employment:, date: Date.parse(date_string), gross_income: amounts[i]
        end
      end
    end

    context "invalid payment period" do
      let(:mock_analyser) { instance_double PaymentPeriodAnalyser, period_pattern: :testing }

      before do
        allow(PaymentPeriodAnalyser).to receive(:new).and_return(mock_analyser)
      end

      it "raises an argument error with period :unknown" do
        expect { described_class.call(employment) }.to raise_error ArgumentError, "unexpected period testing"
      end
    end
  end
end

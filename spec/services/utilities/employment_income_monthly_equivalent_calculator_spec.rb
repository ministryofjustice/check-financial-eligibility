require "rails_helper"

RSpec.describe Utilities::EmploymentIncomeMonthlyEquivalentCalculator do
  let(:instance) { described_class.new(employment) }
  let(:assessment) { create :assessment }
  let(:employment) { create :employment, assessment: }
  let(:payments) { employment.employment_payments.order(:date) }

  before do
    stub_request(:get, "https://www.gov.uk/bank-holidays.json")
      .to_return(body: file_fixture("bank-holidays.json").read)
  end

  context "with valid payment period" do
    before do
      create_employment_payment_records
      allow(instance).to receive(:monthly_to_monthly).and_call_original
      allow(instance).to receive(:four_weekly_to_monthly).and_call_original
      allow(instance).to receive(:two_weekly_to_monthly).and_call_original
      allow(instance).to receive(:weekly_to_monthly).and_call_original
      allow(instance).to receive(:blunt_average).and_call_original
      instance.call
    end

    context "with monthly payment frequency and non varying gross_income" do
      let(:dates) { %w[2022-01-31 2022-02-28 2022-03-31] }
      let(:gross_income) { [2456.83] * 3 }

      it "calls monthly_to_monthly at least once per period" do
        expect(instance).to have_received(:monthly_to_monthly).at_least(3).times
      end

      it "populates gross_income_monthly_equiv with expected values" do
        expect(payments.map(&:gross_income_monthly_equiv)).to eq gross_income
      end

      it "populates tax_monthly_equiv with expected values" do
        expect(payments.map(&:tax_monthly_equiv)).to all(eq(-810.75))
      end

      it "populates national_insurance_monthly_equiv with expected values" do
        expect(payments.map(&:national_insurance_monthly_equiv)).to all(eq(-245.68))
      end
    end

    context "with monthly payment frequency and gross_income varying by < £60" do
      let(:dates) { %w[2022-01-31 2022-02-28 2022-03-31] }
      let(:gross_income) { [2456.83, 2412.66, 2447.33] }

      it "calls monthly_to_monthly at least once per period" do
        expect(instance).to have_received(:monthly_to_monthly).at_least(3).times
      end

      it "populates gross_income_monthly_equiv with expected values" do
        expect(payments.map(&:gross_income_monthly_equiv)).to eq gross_income
      end

      it "populates tax_monthly_equiv with expected values" do
        expect(payments.map(&:tax_monthly_equiv)).to eq [-810.75, -796.18, -807.62]
      end

      it "populates national_insurance_monthly_equiv with expected values" do
        expect(payments.map(&:national_insurance_monthly_equiv)).to eq [-245.68, -241.27, -244.73]
      end
    end

    context "with four-weekly payment frequency and non varying gross_income" do
      let(:dates) { %w[2022-01-14 2022-02-11 2022-03-11] }
      let(:gross_income) { [2456.83] * 3 }

      it "calls four_weekly_to_monthly at least once per period" do
        expect(instance).to have_received(:four_weekly_to_monthly).at_least(3).times
      end

      it "populates gross_income_monthly_equiv with expected values" do
        expect(payments.map(&:gross_income_monthly_equiv)).to all(eq(2661.57))
      end

      it "populates tax_monthly_equiv with expected values" do
        expect(payments.map(&:tax_monthly_equiv)).to all(eq(-878.31))
      end

      it "populates national_insurance_monthly_equiv with expected values" do
        expect(payments.map(&:national_insurance_monthly_equiv)).to all(eq(-266.15))
      end
    end

    context "with four-weekly payment frequency and varying gross_income" do
      let(:dates) { %w[2022-01-14 2022-02-11 2022-03-11] }
      let(:gross_income) { [2456.83, 2412.66, 2447.33] }

      it "calls four_weekly_to_monthly at least once per period" do
        expect(instance).to have_received(:four_weekly_to_monthly).at_least(3).times
      end

      it "populates gross_income_monthly_equiv with expected values" do
        expect(payments.map(&:gross_income_monthly_equiv).uniq).to eq [2661.57, 2613.72, 2651.27]
      end

      it "populates tax_monthly_equiv with expected values" do
        expect(payments.map(&:tax_monthly_equiv)).to eq [-878.31, -862.53, -874.92]
      end

      it "populates national_insurance_monthly_equiv with expected values" do
        expect(payments.map(&:national_insurance_monthly_equiv)).to eq [-266.15, -261.38, -265.12]
      end
    end

    context "with two-weekly payment frequency and non varying gross_income" do
      let(:dates) { %w[2022-01-14 2022-01-28 2022-02-11 2022-02-25 2022-03-11 2022-03-25] }
      let(:gross_income) { [1000.0, 1000.0, 1000.0, 1000.0, 1000.0, 1000.0] }

      it "calls two_weekly_to_monthly at least once per period" do
        expect(instance).to have_received(:two_weekly_to_monthly).at_least(6).times
      end

      it "populates gross_income_monthly_equiv with expected values" do
        expect(payments.map(&:gross_income_monthly_equiv)).to all(eq(2166.67))
      end

      it "populates tax_monthly_equiv with expected values" do
        expect(payments.map(&:tax_monthly_equiv)).to all(eq(-715.0))
      end

      it "populates national_insurance_monthly_equiv with expected values" do
        expect(payments.map(&:national_insurance_monthly_equiv)).to all(eq(-216.67))
      end
    end

    context "with two-weekly payment frequency and varying gross_income" do
      let(:dates) { %w[2022-01-14 2022-01-28 2022-02-11 2022-02-25 2022-03-11 2022-03-25] }
      let(:gross_income) { [1000.0, 2000.0, 1000.0, 2000.0, 1000.0, 2000.0] }

      it "calls two_weekly_to_monthly at least once per period" do
        expect(instance).to have_received(:two_weekly_to_monthly).at_least(6).times
      end

      it "populates gross_income_monthly_equiv with expected values" do
        expect(payments.map(&:gross_income_monthly_equiv)).to eq [2166.67, 4333.33] * 3
      end

      it "populates tax_monthly_equiv with expected values" do
        expect(payments.map(&:tax_monthly_equiv)).to eq [-715.0, -1430.0] * 3
      end

      it "populates national_insurance_monthly_equiv with expected values" do
        expect(payments.map(&:national_insurance_monthly_equiv)).to eq [-216.67, -433.33] * 3
      end
    end

    context "with weekly payment frequency and non varying gross_income" do
      let(:dates) { %w[2022-01-07 2022-01-14 2022-01-21 2022-01-28 2022-02-04 2022-02-11 2022-02-18 2022-02-25 2022-03-04 2022-03-11 2022-03-18 2022-03-25] }
      let(:gross_income) { [1000.0, 1000.0, 1000.0, 1000.0, 1000.0, 1000.0, 1000.0, 1000.0, 1000.0, 1000.0, 1000.0, 1000.0] }

      it "calls weekly_to_monthly at least once per period" do
        expect(instance).to have_received(:weekly_to_monthly).at_least(12).times
      end

      it "populates gross_income_monthly_equiv with expected values" do
        expect(payments.map(&:gross_income_monthly_equiv)).to eq([4333.33] * 12)
      end

      it "populates tax_monthly_equiv with expected values" do
        expect(payments.map(&:tax_monthly_equiv)).to eq [-1430.0] * 12
      end

      it "populates national_insurance_monthly_equiv with expected values" do
        expect(payments.map(&:national_insurance_monthly_equiv)).to eq [-433.33] * 12
      end
    end

    context "with weekly payment frequency and varying gross_income" do
      let(:dates) { %w[2022-01-07 2022-01-14 2022-01-21 2022-01-28 2022-02-04 2022-02-11 2022-02-18 2022-02-25 2022-03-04 2022-03-11 2022-03-18 2022-03-25] }
      let(:gross_income) { [1000.0, 2000.0, 1000.0, 2000.0, 1000.0, 2000.0, 1000.0, 2000.0, 1000.0, 2000.0, 1000.0, 2000.0] }

      it "calls weekly_to_monthly at least once per period" do
        expect(instance).to have_received(:weekly_to_monthly).at_least(12).times
      end

      it "populates gross_income_monthly_equiv with gross income" do
        expect(payments.map(&:gross_income_monthly_equiv)).to eq([4333.33, 8666.67] * 6)
      end

      it "populates tax_monthly_equiv with expected values" do
        expect(payments.map(&:tax_monthly_equiv)).to eq [-1430.0, -2860.0] * 6
      end

      it "populates national_insurance_monthly_equiv with expected values" do
        expect(payments.map(&:national_insurance_monthly_equiv)).to eq [-433.33, -866.67] * 6
      end
    end

    context "with irregular payment frequency, requiring a blunt_average, and non varying gross_income" do
      let(:dates) { %w[2021-07-15 2021-08-20 2021-09-17 2021-10-15 2021-11-12 2021-12-10] }
      let(:gross_income) { [100, 100, 100, 100, 100, 100] }

      it "calls blunt_average at least once per period" do
        expect(instance).to have_received(:blunt_average).at_least(6).times
      end

      it "populates gross_income_monthly_equiv with gross income" do
        expect(payments.map(&:gross_income_monthly_equiv)).to all(eq(100))
      end

      it "populates tax_monthly_equiv with expected values" do
        expect(payments.map(&:tax_monthly_equiv)).to all(eq(-33))
      end

      it "populates national_insurance_monthly_equiv with expected values" do
        expect(payments.map(&:national_insurance_monthly_equiv)).to all(eq(-10))
      end
    end

    context "with irregular payment frequency, requiring a blunt_average, and varying gross_income" do
      let(:dates) { %w[2021-07-15 2021-08-20 2021-09-17 2021-10-15 2021-11-12 2021-12-10] }
      let(:gross_income) { [100, 200, 100, 200, 100, 200] }

      it "calls blunt_average at least once per period" do
        expect(instance).to have_received(:blunt_average).at_least(6).times
      end

      it "populates gross_income_monthly_equiv with gross income" do
        expect(payments.map(&:gross_income_monthly_equiv)).to all(eq(150))
      end

      it "populates tax_monthly_equiv with expected values" do
        expect(payments.map(&:tax_monthly_equiv)).to all(eq(-49.50))
      end

      it "populates national_insurance_monthly_equiv with expected values" do
        expect(payments.map(&:national_insurance_monthly_equiv)).to all(eq(-15))
      end
    end

    def create_employment_payment_records
      dates.each_with_index do |date_string, i|
        create :employment_payment, employment:, date: Date.parse(date_string), gross_income: gross_income[i]
      end
    end
  end

  context "with invalid payment period" do
    let(:mock_analyser) { instance_double Utilities::PaymentPeriodAnalyser, period_pattern: :testing }

    before do
      allow(Utilities::PaymentPeriodAnalyser).to receive(:new).and_return(mock_analyser)
    end

    it "raises an argument error for unacceptable period" do
      expect { described_class.call(employment) }.to raise_error ArgumentError, "unexpected frequency testing"
    end
  end
end

require "rails_helper"

RSpec.describe Employment do
  describe "#calculate_monthly_amounts!", :vcr do
    let(:employment) { create :employment, calculation_method: calculation_method }
    let(:assessment) { employment.assessment }
    let(:calculation_method) { nil }
    let(:gross) { 2022.35 }
    let(:bik) { 44.32 }
    let(:tax) { 677.27 }
    let(:insurance) { 98.65 }
    let(:date_strings) { %w[2021-09-30 2021-10-29 2021-11-30] }

    # new tests for new employment calculations
    describe "calculate gross income!" do
      before { setup_employment_and_payments }

      context "variance less than 60 GBP" do
        let(:amounts) { [2000, 1990, 2010] }

        it "populates with the most recent monthly employment equivalent" do
          employment.__send__(:calculate_monthly_gross_income!)
          expect(employment.monthly_gross_income).to eq amounts.last
        end

        it "does not add a remark" do
          assessment_double = instance_double(Assessment, submission_date: Time.zone.today, marked_for_destruction?: false)
          remarks_double = instance_double(Remarks)
          allow(employment).to receive(:assessment).and_return(assessment_double)
          allow(assessment_double).to receive(:remarks).and_return(remarks_double)
          expect(remarks_double).not_to receive(:add)
          employment.__send__(:calculate_monthly_gross_income!)
        end

        it "sets the calculation method" do
          employment.__send__(:calculate_monthly_gross_income!)
          expect(employment.calculation_method).to eq "most_recent"
        end
      end

      context "variance greater than 60 GBP" do
        let(:amounts) { [2000, 1930, 2010] }

        it "populates with the most a blunt average" do
          employment.__send__(:calculate_monthly_gross_income!)
          expect(employment.monthly_gross_income).to eq(amounts.sum / amounts.size)
        end

        it "adds a remark" do
          employment.__send__(:calculate_monthly_gross_income!)
          remarks_hash = assessment.remarks.remarks_hash
          expect(remarks_hash.dig(:employment_gross_income, :amount_variation)).to match_array(employment.employment_payments.map(&:client_id))
        end

        it "sets the calculation method" do
          employment.__send__(:calculate_monthly_gross_income!)
          expect(employment.calculation_method).to eq "blunt_average"
        end
      end
    end

    describe "#calculate_monthly_ni_tax!" do
      before { setup_ni_and_tax }

      context "when using the blunt average" do
        let(:calculation_method) { "blunt_average" }
        let(:tax_amounts) { [100, 200.01, 120] }
        let(:ni_amounts) { [10.94, 10.33, 12.88] }

        it "uses the blunt average to calculate monthly NI" do
          employment.__send__(:calculate_monthly_ni_tax!)
          expect(employment.monthly_national_insurance).to eq 11.38
        end

        it "uses the blunt average to calculate monthly tax" do
          employment.__send__(:calculate_monthly_ni_tax!)
          expect(employment.monthly_tax).to eq 140.0
        end
      end

      context "when using the most recent" do
        let(:calculation_method) { "most_recent" }
        let(:tax_amounts) { [100, 200.01, 120] }
        let(:ni_amounts) { [10.94, 10.33, 12.88] }

        it "uses the most recent payment for monthly NI" do
          employment.__send__(:calculate_monthly_ni_tax!)
          expect(employment.monthly_national_insurance).to eq 12.88
        end

        it "uses the most recent payment for monthly tax" do
          employment.__send__(:calculate_monthly_ni_tax!)
          expect(employment.monthly_tax).to eq 120
        end
      end

      context "calculation method not populated" do
        let(:calculation_method) { nil }
        let(:tax_amounts) { [100, 200.01, 120] }
        let(:ni_amounts) { [10.94, 10.33, 12.88] }

        it "raises" do
          expect {
            employment.__send__(:calculate_monthly_ni_tax!)
          }.to raise_error RuntimeError, "invalid calculation method: nil"
        end
      end
    end

    describe ".calculate!" do
      it "calls the calculate methods" do
        expect(employment).to receive(:calculate_monthly_gross_income!)
        expect(Calculators::TaxNiRefundCalculator).to receive(:call)
        expect(employment).to receive(:calculate_monthly_ni_tax!)
        employment.calculate!
      end
    end
  end

  def setup_employment_and_payments
    date_strings.each_with_index do |date_string, i|
      create :employment_payment,
             employment: employment,
             date: Date.parse(date_string),
             gross_income: gross,
             gross_income_monthly_equiv: amounts[i],
             benefits_in_kind: bik,
             tax: tax,
             national_insurance: insurance
    end
  end

  def setup_ni_and_tax
    date_strings.each_with_index do |date_string, i|
      create :employment_payment,
             employment: employment,
             date: Date.parse(date_string),
             gross_income: gross,
             gross_income_monthly_equiv: gross,
             benefits_in_kind: bik,
             tax: tax_amounts[i],
             tax_monthly_equiv: tax_amounts[i],
             national_insurance: ni_amounts[i],
             national_insurance_monthly_equiv: ni_amounts[i]
    end
  end
end

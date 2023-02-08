require "rails_helper"

module Calculators
  RSpec.describe EmploymentIncomeCalculator, :vcr do
    let(:assessment) { create :assessment, gross_income_summary: build(:gross_income_summary) }
    let(:employment1) { create :employment, assessment: }
    let(:employment2) { create :employment, assessment: }
    let(:gross) { BigDecimal(rand(2022.35...3096.52), 2) }
    let(:tax) { (gross * 0.23).round(2) * -1 }
    let(:ni_cont) { (gross * 0.052).round(2) * -1 }
    let(:benefits_in_kind) { BigDecimal(rand(-77.0...-25.0), 2) }
    let(:month1) { Date.parse("2021-04-30") }
    let(:month2) { Date.parse("2021-05-30") }
    let(:month3) { Date.parse("2021-06-30") }
    let(:dates) { [month1, month2, month3] }
    let(:expected_gross_income) { gross + benefits_in_kind + gross + benefits_in_kind }
    let(:expected_deductions) { tax + ni_cont + tax + ni_cont }
    let(:expected_benefits_in_kind) { benefits_in_kind + benefits_in_kind }
    let(:expected_tax) { tax + tax }
    let(:expected_national_insurance) { ni_cont + ni_cont }

    context "when there is only one employment" do
      it "does not call the Multiple Employments Calculator" do
        allow(Calculators::EmploymentMonthlyValueCalculator).to receive(:call)
        described_class.call(submission_date: assessment.submission_date,
                             employment: employment1)
      end

      it "requests an employment calculation" do
        expect(Calculators::EmploymentMonthlyValueCalculator).to receive(:call)
        described_class.call(submission_date: assessment.submission_date,
                             employment: employment1)
      end
    end

    describe "fixed income allowance" do
      context "at least one employment record exists" do
        it "adds the fixed employment allowance from the threshold files" do
          create_payments_for_single_employment
          expect(described_class.call(submission_date: assessment.submission_date,
                                      employment: assessment.employments.first).fixed_employment_allowance).to eq(-45)
        end
      end

      context "no employment records exist" do
        it "leaves the fixed employment allowance as zero" do
          expect(described_class.call(submission_date: assessment.submission_date,
                                      employment: assessment.employments.first).fixed_employment_allowance).to eq 0.0
        end
      end
    end

    def create_payments_for_single_employment
      dates.each do |date|
        create :employment_payment,
               date:,
               employment: employment1,
               gross_income: gross,
               tax:,
               national_insurance: ni_cont,
               benefits_in_kind:
      end
    end
  end
end

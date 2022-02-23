require "rails_helper"

module Calculators
  RSpec.describe EmploymentIncomeCalculator, :vcr do
    let(:assessment) { create :assessment }
    let!(:gross_income_summary) { create :gross_income_summary, assessment: assessment }
    let!(:disposable_income_summary) { create :disposable_income_summary, assessment: assessment }
    let(:employment1) { create :employment, assessment: assessment }
    let(:employment2) { create :employment, assessment: assessment }
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

    context "when there is more than one employment" do
      it "calls the Multiple Employments Calculator" do
        allow(assessment).to receive(:employments).and_return([employment1, employment2])
        expect(Calculators::MultipleEmploymentsCalculator).to receive(:call).with(assessment)
        described_class.call(assessment)
      end

      it "does not call #calculate! on each employment record" do
        allow(assessment).to receive(:employments).and_return([employment1, employment2])
        expect(employment1).not_to receive(:calculate!)
        expect(employment2).not_to receive(:calculate!)
        allow(Calculators::MultipleEmploymentsCalculator).to receive(:call).with(assessment)
        described_class.call(assessment)
      end

      it "updates both employment records" do
        create_payments_for_multiple_employments
        described_class.call(assessment)
        [employment1.reload, employment2.reload].each do |emp|
          expect(emp.monthly_gross_income).to eq 0
          expect(emp.monthly_tax).to eq 0
          expect(emp.monthly_national_insurance).to eq 0
          expect(emp.monthly_benefits_in_kind).to eq 0
        end
      end
    end

    context "when there is only one employment" do
      it "does not call the Multiple Employments Calculator" do
        allow(assessment).to receive(:employments).and_return([employment1])
        allow(assessment.employments.first).to receive(:calculate!)
        expect(Calculators::MultipleEmploymentsCalculator).not_to receive(:call)
        described_class.call(assessment)
      end

      it "calls #calculate! on each employment record" do
        allow(assessment).to receive(:employments).and_return([employment1])
        allow(assessment.employments.first).to receive(:calculate!)
        described_class.call(assessment)
      end

      it "updates both employment records" do
        create_payments_for_multiple_employments
        described_class.call(assessment)
        [employment1.reload, employment2.reload].each do |emp|
          expect(emp.monthly_gross_income).to eq 0
          expect(emp.monthly_tax).to eq 0
          expect(emp.monthly_national_insurance).to eq 0
          expect(emp.monthly_benefits_in_kind).to eq 0
        end
      end
    end

    it "updates the gross_income_summary with a sum of the employment income and biks" do
      create_payments_for_multiple_employments
      described_class.call(assessment)
      expect(gross_income_summary.gross_employment_income).to eq 0
      expect(gross_income_summary.benefits_in_kind).to eq 0
    end

    it "updates the disposable income summary with sum of employment ni conts and tax" do
      create_payments_for_multiple_employments
      described_class.call(assessment)
      expect(disposable_income_summary.employment_income_deductions).to eq 0
      expect(disposable_income_summary.tax).to eq 0
      expect(disposable_income_summary.national_insurance).to eq 0
    end

    describe "fixed income allowance" do
      context "at least one employment record exists" do
        it "adds the fixed employment allowance from the threshold files" do
          create_payments_for_single_employment
          described_class.call(assessment)
          expect(disposable_income_summary.fixed_employment_allowance).to eq(-45)
        end
      end

      context "no employment records exist" do
        it "leaves the fixed employment allowance as zero" do
          described_class.call(assessment)
          expect(disposable_income_summary.fixed_employment_allowance).to eq 0.0
        end
      end
    end

    def create_payments_for_multiple_employments
      [employment1, employment2].each do |employment|
        dates.each do |date|
          create :employment_payment,
                 date: date,
                 employment: employment,
                 gross_income: gross,
                 tax: tax,
                 national_insurance: ni_cont,
                 benefits_in_kind: benefits_in_kind
        end
      end
    end

    def create_payments_for_single_employment
      dates.each do |date|
        create :employment_payment,
               date: date,
               employment: employment1,
               gross_income: gross,
               tax: tax,
               national_insurance: ni_cont,
               benefits_in_kind: benefits_in_kind
      end
    end
  end
end

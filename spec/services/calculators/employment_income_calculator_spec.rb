require 'rails_helper'

module Calculators
  RSpec.describe EmploymentIncomeCalculator, :vcr do
    let(:assessment) { create :assessment }
    let!(:gross_income_summary) { create :gross_income_summary, assessment: assessment }
    let!(:disposable_income_summary) { create :disposable_income_summary, assessment: assessment }
    let(:employment1) { create :employment, assessment: assessment }
    let(:employment2) { create :employment, assessment: assessment }
    let(:gross) { Faker::Number.between(from: 2022.35, to: 3096.52).round(2) }
    let(:tax) { (gross * 0.23).round(2) * -1 }
    let(:ni_cont) { (gross * 0.052).round(2) * -1 }
    let(:benefits_in_kind) { Faker::Number.between(from: -77.0, to: -25.0).round(2) }
    let(:month1) { Date.parse('2021-04-30') }
    let(:month2) { Date.parse('2021-05-30') }
    let(:month3) { Date.parse('2021-06-30') }
    let(:dates) { [month1, month2, month3] }
    let(:expected_gross_income) { gross + benefits_in_kind + gross + benefits_in_kind }
    let(:expected_deductions) { tax + ni_cont + tax + ni_cont }

    it 'calls #calculate_monthly_amounts! on each employment record' do
      employment1
      employment2
      allow(employment1).to receive(:calculate_monthly_amounts!)
      allow(employment2).to receive(:calculate_monthly_amounts!)
      described_class.call(assessment)
    end

    it 'updates both employment records' do
      create_payments
      described_class.call(assessment)
      [employment1.reload, employment2.reload].each do |emp|
        expect(emp.monthly_gross_income).to eq gross
        expect(emp.monthly_tax).to eq tax
        expect(emp.monthly_national_insurance).to eq ni_cont
        expect(emp.monthly_benefits_in_kind).to eq benefits_in_kind
      end
    end

    it 'updates the gross_income_summary iwth a sum of the employment income and biks' do
      create_payments
      described_class.call(assessment)
      expect(gross_income_summary.gross_employment_income).to be_within(0.001).of(expected_gross_income.to_d)
    end

    it 'updates the disposable income summary with sum of employment ni conts and tax' do
      create_payments
      described_class.call(assessment)
      expect(disposable_income_summary.employment_income_deductions).to be_within(0.001).of(expected_deductions.to_d)
    end

    describe 'fixed income allowance' do
      context 'at least one employment record exists' do
        it 'adds the fixed employment allowance from the threshold files' do
          create_payments
          described_class.call(assessment)
          expect(disposable_income_summary.fixed_employment_allowance).to eq 45.0
        end
      end

      context 'no employment records exist' do
        it 'leaves the fixed employment allowance as zero' do
          described_class.call(assessment)
          expect(disposable_income_summary.fixed_employment_allowance).to eq 0.0
        end
      end
    end

    def create_payments
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
  end
end

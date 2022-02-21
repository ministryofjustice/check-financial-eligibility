require 'rails_helper'

RSpec.describe Calculators::TaxNiRefundCalculator do
  before do
    setup_employment_and_payments
    Calculators::TaxNiRefundCalculator.call(employment)
  end

  let(:employment) { create :employment}

  let(:date_strings) { %w[2021-09-30 2021-10-29 2021-11-30] }

  context 'when there are no refunds' do
    let(:ni_amounts) { [-10, -20, -30]}
    let(:tax_amounts) { [-50, -60, -70]}


    it 'does not change the tax amount value' do
      expect(employment.employment_payments.map(&:tax)).to match_array(tax_amounts)
    end

    it 'does not change the NI amount value' do
      expect(employment.employment_payments.map(&:national_insurance)).to match_array(ni_amounts)
    end
  end

  context 'when there are tax refunds only' do
    let(:ni_amounts) { [-10, -20, -30]}
    let(:tax_amounts) { [50, -60, -70]}

    it 'changes the tax amount value' do
      expect(employment.reload.employment_payments.map(&:tax)).to match_array([0, -60, -70])
    end

    it 'does not change the NI amount value' do
      expect(employment.employment_payments.map(&:national_insurance)).to match_array(ni_amounts)
    end
  end

  context 'when there are tax and NI refunds' do
    let(:ni_amounts) { [10, -20, -30]}
    let(:tax_amounts) { [50, -60, -70]}

    it 'changes the tax amount value' do
      expect(employment.reload.employment_payments.map(&:tax)).to match_array([0, -60, -70])
    end

    it 'changes the NI amount value' do
      expect(employment.employment_payments.map(&:national_insurance)).to match_array([0, -20, -30])
    end
  end


  def setup_employment_and_payments
    date_strings.each_with_index do |date_string, i|
      create :employment_payment,
             employment: employment,
             date: Date.parse(date_string),
             gross_income: 1000,
             gross_income_monthly_equiv: 1000,
             benefits_in_kind: 100,
             tax: tax_amounts[i],
             national_insurance: ni_amounts[i]
    end
  end
end


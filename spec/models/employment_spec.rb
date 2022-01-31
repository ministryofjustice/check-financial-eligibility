require "rails_helper"

RSpec.describe Employment do
  describe "#calculate_monthly_amounts!", :vcr do
    let(:employment) { create :employment }
    let(:gross) { 2022.35 }
    let(:bik) { 44.32 }
    let(:tax) { 677.27 }
    let(:insurance) { 98.65 }
    let(:date_strings) { %w[2021-09-30 2021-10-29 2021-11-30] }

    it "updates the employment record with monthly equivalent derived from employment payment records" do
      setup_employment_and_payments
      employment.calculate_monthly_amounts!
      expect(employment.monthly_gross_income).to eq gross
      expect(employment.monthly_benefits_in_kind).to eq bik
      expect(employment.monthly_tax).to eq tax
      expect(employment.monthly_national_insurance).to eq insurance
    end
  end

  def setup_employment_and_payments
    date_strings.each do |date_string|
      create :employment_payment,
             employment: employment,
             date: Date.parse(date_string),
             gross_income: gross,
             benefits_in_kind: bik,
             tax: tax,
             national_insurance: insurance
    end
  end
end

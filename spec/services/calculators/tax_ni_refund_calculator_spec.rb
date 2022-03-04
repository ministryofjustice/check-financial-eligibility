require "rails_helper"

RSpec.describe Calculators::TaxNiRefundCalculator do
  before { setup_employment_and_payments }

  subject(:calculator) { described_class.call(employment) }

  let(:employment) { create :employment }

  let(:date_strings) { %w[2021-09-30 2021-10-29 2021-11-30] }

  let(:assessment_double) { instance_double(Assessment, submission_date: Time.zone.today, marked_for_destruction?: false, update!: nil) }

  let(:remarks_double) do
    remarks_double = instance_double(Remarks)
    allow(employment).to receive(:assessment).and_return(assessment_double)
    allow(assessment_double).to receive(:remarks).and_return(remarks_double)
    remarks_double
  end

  context "when there are no refunds" do
    let(:ni_amounts) { [-10, -20, -30] }
    let(:tax_amounts) { [-50, -60, -70] }

    it "does not change the tax amount value" do
      calculator
      expect(employment.employment_payments.map(&:tax)).to match_array(tax_amounts)
    end

    it "does not change the NI amount value" do
      calculator
      expect(employment.employment_payments.map(&:national_insurance)).to match_array(ni_amounts)
    end

    it "does not add a remark" do
      expect(remarks_double).not_to receive(:add)

      calculator
    end
  end

  context "when there are tax refunds only" do
    let(:ni_amounts) { [-10, -20, -30] }
    let(:tax_amounts) { [50, -60, -70] }

    it "changes the tax amount value" do
      calculator
      expect(employment.reload.employment_payments.map(&:tax)).to match_array([0, -60, -70])
    end

    it "does not change the NI amount value" do
      calculator
      expect(employment.employment_payments.map(&:national_insurance)).to match_array(ni_amounts)
    end

    it "adds remarks for tax refund" do
      refund_payment = employment.employment_payments.detect { |pmt| pmt.tax > 0 }
      expect(remarks_double).to receive(:add).with(:employment_tax, :refunds, [refund_payment.client_id])

      calculator
    end
  end

  context "when there are tax and NI refunds" do
    let(:ni_amounts) { [10, -20, -30] }
    let(:tax_amounts) { [50, -60, -70] }

    it "changes the tax amount value" do
      calculator
      expect(employment.reload.employment_payments.map(&:tax)).to match_array([0, -60, -70])
    end

    it "changes the NI amount value" do
      calculator
      expect(employment.employment_payments.map(&:national_insurance)).to match_array([0, -20, -30])
    end

    it "add remarks for both tax and NI refunds" do
      refund_tax_payment = employment.employment_payments.detect { |pmt| pmt.tax > 0 }
      refund_ni_payment = employment.employment_payments.detect { |pmt| pmt.national_insurance > 0 }
      expect(remarks_double).to receive(:add).with(:employment_tax, :refunds, [refund_tax_payment.client_id])
      expect(remarks_double).to receive(:add).with(:employment_nic, :refunds, [refund_ni_payment.client_id])

      calculator
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

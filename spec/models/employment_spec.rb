require "rails_helper"

RSpec.describe Employment do
  describe "#calculate_monthly_amounts!", :vcr do
    let(:employment) { create :employment }
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
          employment.calculate_monthly_gross_income!
          expect(employment.monthly_gross_income).to eq amounts.last
        end

        it "does not add a remark" do
          assessment_double = instance_double(Assessment, submission_date: Date.today, marked_for_destruction?: false)
          remarks_double = instance_double(Remarks)
          allow(employment).to receive(:assessment).and_return(assessment_double)
          allow(assessment_double).to receive(:remarks).and_return(remarks_double)
          expect(remarks_double).not_to receive(:add)
          employment.calculate_monthly_gross_income!
        end
      end

      context "variance greater than 60 GBP" do
        let(:amounts) { [2000, 1930, 2010] }

        it "populates with the most a blunt average" do
          employment.calculate_monthly_gross_income!
          expect(employment.monthly_gross_income).to eq(amounts.sum / amounts.size)
        end

        it "adds a remark" do
          assessment_double = instance_double(Assessment, submission_date: Date.today, marked_for_destruction?: false)
          remarks_double = instance_double(Remarks)
          allow(employment).to receive(:assessment).and_return(assessment_double)
          allow(assessment_double).to receive(:remarks).and_return(remarks_double)
          expect(remarks_double).to receive(:add).with(:employment_gross_income, :amount_variation, employment.employment_payments.map(&:client_id))
          employment.calculate_monthly_gross_income!
        end
      end
    end

    context "no tax or NIC refunds" do
      context "variance less than £60" do
        it "sets the gross_income to the most recent employment payment gross income equivalent"
        it "sets the tax and NIC to the most recent employment payment gross income equivalent"
        it "sets benefits in kind to zero"
      end

      context "variance greater than 60" do
        it "sets the gross income to an average over the three months"
        it "sets the tax and NIC to an average over the thee months"
        it "sets benefits in kind to zero"
      end
    end

    context "tax refund"
    context "NIC refund"

    # it "updates the employment record with monthly equivalent derived from employment payment records" do
    #   setup_employment_and_payments
    #   employment.calculate_monthly_amounts!
    #   expect(employment.monthly_gross_income).to eq gross
    #   expect(employment.monthly_benefits_in_kind).to eq bik
    #   expect(employment.monthly_tax).to eq tax
    #   expect(employment.monthly_national_insurance).to eq insurance
    # end
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
end

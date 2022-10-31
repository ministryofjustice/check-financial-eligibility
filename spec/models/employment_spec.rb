require "rails_helper"

RSpec.describe Employment do
  describe "#calculate!" do
    let(:employment) { create(:employment) }

    it "calls the tax and national insurance refund calculator" do
      allow(Calculators::TaxNiRefundCalculator).to receive(:call)

      employment.calculate!

      expect(Calculators::TaxNiRefundCalculator)
        .to have_received(:call)
        .with(employment)
        .exactly(1).time
    end

    context "when there are employment payments" do
      before do
        _payment = create(
          :employment_payment,
          employment:,
          date: Date.yesterday,
          gross_income_monthly_equiv: 100,
          national_insurance_monthly_equiv: 10,
          tax_monthly_equiv: 20,
        )
        _recent_payment = create(
          :employment_payment,
          employment:,
          date: Date.current,
          gross_income_monthly_equiv: 500,
          national_insurance_monthly_equiv: 20,
          tax_monthly_equiv: 50,
        )
      end

      context "when variation in employment income is below the threshold" do
        before do
          variation_checker = instance_double(
            Utilities::EmploymentIncomeVariationChecker,
            below_threshold?: true,
          )
          allow(Utilities::EmploymentIncomeVariationChecker)
            .to receive(:new)
            .and_return(variation_checker)
        end

        it "updates the monthly gross income, national insurance, and tax to " \
           "the most recent payment" do
          employment.calculate!

          expect(employment).to have_attributes(
            calculation_method: "most_recent",
            monthly_gross_income: 500,
            monthly_national_insurance: 20,
            monthly_tax: 50,
          )
        end

        it "does not add a remark to the assessment" do
          employment.calculate!

          remarks = employment.assessment.remarks.remarks_hash
          expect(remarks).to be_blank
        end
      end

      context "when variation in employment income is above the threshold" do
        before do
          variation_checker = instance_double(
            Utilities::EmploymentIncomeVariationChecker,
            below_threshold?: false,
          )
          allow(Utilities::EmploymentIncomeVariationChecker)
            .to receive(:new)
            .and_return(variation_checker)
        end

        it "updates the monthly gross income, national insurance, and tax to " \
           "the blunt average" do
          employment.calculate!

          expect(employment).to have_attributes(
            calculation_method: "blunt_average",
            monthly_gross_income: 300,
            monthly_national_insurance: 15,
            monthly_tax: 35,
          )
        end

        it "adds a remark to the assessment" do
          employment.calculate!

          remarks = employment.assessment.remarks.remarks_hash
          employment_payments = employment.employment_payments
          expect(remarks[:employment_gross_income][:amount_variation])
            .to contain_exactly(*employment_payments.map(&:client_id))
        end
      end
    end

    context "when there are no employment payments" do
      it "zeros the monthly gross income, national insurance, and tax" do
        employment.calculate!

        expect(employment).to have_attributes(
          calculation_method: "blunt_average",
          monthly_gross_income: 0,
          monthly_national_insurance: 0,
          monthly_tax: 0,
        )
      end
    end
  end
end

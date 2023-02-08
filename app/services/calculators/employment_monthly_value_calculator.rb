module Calculators
  class EmploymentMonthlyValueCalculator
    class << self
      def call(employment, submission_date)
        Calculators::TaxNiRefundCalculator.call(employment)
        payments = employment.employment_payments
        if employment_income_variation_below_threshold?(payments, submission_date)
          calculation = :most_recent
          add_variation_remarks = false
        else
          calculation = :blunt_average
          add_variation_remarks = true
        end

        monthly_values = calculate_monthly_values(payments, calculation:)

        # TODO: Return these values instead of persisting them
        persist_values(employment, monthly_values, add_variation_remarks)
      end

      def employment_income_variation_below_threshold?(payments, submission_date)
        return false if payments.none?

        Utilities::EmploymentIncomeVariationChecker.new(payments).below_threshold?(submission_date)
      end

      def calculate_monthly_values(payments, calculation:)
        {
          calculation_method: calculation.to_s,
          monthly_gross_income: send(calculation, payments, :gross_income_monthly_equiv),
          monthly_national_insurance: send(calculation, payments, :national_insurance_monthly_equiv),
          monthly_tax: send(calculation, payments, :tax_monthly_equiv),
        }
      end

      def blunt_average(payments, attribute)
        values = payments.map(&attribute)
        return 0.0 if values.empty?

        (values.sum / values.size).round(2)
      end

      def most_recent(payments, attribute)
        payment = payments.order(:date).last
        payment.public_send(attribute)
      end

      def persist_values(employment, monthly_values, add_variation_remarks)
        employment.update!(monthly_values)

        return unless add_variation_remarks

        remarks = employment.assessment.remarks
        remarks.add(:employment_gross_income, :amount_variation, employment.employment_payments.map(&:client_id))
        employment.assessment.update!(remarks:)
      end
    end
  end
end

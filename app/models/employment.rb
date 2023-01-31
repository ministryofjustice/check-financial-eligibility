class Employment < ApplicationRecord
  include MonthlyEquivalentCalculator

  belongs_to :assessment

  has_many :employment_payments, dependent: :destroy

  validates :calculation_method, inclusion: { in: %w[blunt_average most_recent] }, allow_nil: true

  def calculate!(submission_date)
    Calculators::TaxNiRefundCalculator.call(self)

    if employment_payments.any? && employment_income_variation_below_threshold?(submission_date)
      update_monthly_values!(calculation: :most_recent)
    else
      update_monthly_values!(calculation: :blunt_average)
      add_amount_variation_remarks
    end
  end

private

  def employment_income_variation_below_threshold?(submission_date)
    Utilities::EmploymentIncomeVariationChecker.new(employment_payments).below_threshold?(submission_date)
  end

  def update_monthly_values!(calculation:)
    update!(
      calculation_method: calculation.to_s,
      monthly_gross_income: send(calculation, :gross_income_monthly_equiv),
      monthly_national_insurance: send(calculation, :national_insurance_monthly_equiv),
      monthly_tax: send(calculation, :tax_monthly_equiv),
    )
  end

  def blunt_average(attribute)
    values = employment_payments.map(&attribute)
    return 0.0 if values.empty?

    (values.sum / values.size).round(2)
  end

  def most_recent(attribute)
    payment = employment_payments.order(:date).last
    payment.public_send(attribute)
  end

  def add_amount_variation_remarks
    my_remarks = assessment.remarks
    my_remarks.add(
      :employment_gross_income,
      :amount_variation,
      employment_payments.map(&:client_id),
    )
    assessment.update!(remarks: my_remarks)
  end
end

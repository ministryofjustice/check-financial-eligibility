class Employment < ApplicationRecord
  include MonthlyEquivalentCalculator

  delegate :gross_income_summary, to: :assessment

  belongs_to :assessment

  has_many :employment_payments, dependent: :destroy

  validates :calculation_method, inclusion: { in: %w[blunt_average most_recent] }, allow_nil: true

  def calculate!
    calculate_monthly_gross_income!
    Calculators::TaxNiRefundCalculator.call(self)
    calculate_monthly_ni_tax!
  end

  private

  def calculate_monthly_gross_income!
    if Utilities::EmploymentIncomeVariationChecker.new(self).below_threshold?
      update!(
        monthly_gross_income: employment_payments.order(:date).last.gross_income_monthly_equiv,
        calculation_method: "most_recent"
      )
    else
      update!(
        monthly_gross_income: blunt_average(:gross_income_monthly_equiv),
        calculation_method: "blunt_average"
      )
      add_amount_variation_remarks
    end
  end

  def calculate_monthly_ni_tax!
    case calculation_method
    when "blunt_average"
      use_ni_tax_blunt_average
    when "most_recent"
      use_ni_tax_most_recent
    else
      raise RuntimeError, "invalid calculation method: #{calculation_method}"
    end
  end

  def use_ni_tax_blunt_average
    update!(
      monthly_national_insurance: blunt_average(:national_insurance),
      monthly_tax: blunt_average(:tax)
    )
  end

  def use_ni_tax_most_recent
    most_recent_payment = employment_payments.order(:date).last

    update!(
      monthly_national_insurance: most_recent_payment.national_insurance,
      monthly_tax: most_recent_payment.tax
    )
  end

  def blunt_average(attribute)
    values = employment_payments.map(&attribute)
    (values.sum / values.size).round(2)
  end

  def add_amount_variation_remarks
    assessment.remarks.add(:employment_gross_income, :amount_variation, employment_payments.map(&:client_id))
  end
end

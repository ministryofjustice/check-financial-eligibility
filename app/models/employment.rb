class Employment < ApplicationRecord
  include MonthlyEquivalentCalculator

  delegate :gross_income_summary, to: :assessment

  belongs_to :assessment

  has_many :employment_payments, dependent: :destroy

  def calculate_monthly_amounts!
    gross_income = calculate_monthly_equivalent(collection: employment_payments, date_method: :date, amount_method: :gross_income)
    benefits = calculate_monthly_equivalent(collection: employment_payments, date_method: :date, amount_method: :benefits_in_kind)
    tax = calculate_monthly_equivalent(collection: employment_payments, date_method: :date, amount_method: :tax)
    national_insurance = calculate_monthly_equivalent(collection: employment_payments, date_method: :date, amount_method: :national_insurance)
    update!(
      monthly_gross_income: gross_income,
      monthly_benefits_in_kind: benefits,
      monthly_tax: tax,
      monthly_national_insurance: national_insurance
    )
  end
end

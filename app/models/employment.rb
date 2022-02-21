class Employment < ApplicationRecord
  include MonthlyEquivalentCalculator

  delegate :gross_income_summary, to: :assessment

  belongs_to :assessment

  has_many :employment_payments, dependent: :destroy


  def calculate_monthly_gross_income!
    if Utilities::EmploymentIncomeVariationChecker.new(self).below_threshold?
      update!(monthly_gross_income: employment_payments.order(:date).last.gross_income_monthly_equiv)
    else
      update!(monthly_gross_income: blunt_average(:gross_income_monthly_equiv))
      add_amount_variation_remarks
    end
  end

  private

  def blunt_average(attribute)
    values = employment_payments.map(&attribute)
    values.sum / values.size
  end

  def add_amount_variation_remarks
    assessment.remarks.add(:employment, :amount_variation, employment_payments.map(&:client_id))
  end
end

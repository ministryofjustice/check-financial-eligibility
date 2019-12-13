class OtherIncomeSource < ApplicationRecord
  belongs_to :gross_income_summary
  has_many :other_income_payments

  validates :gross_income_summary_id, :name, presence: true

  delegate :assessment, to: :gross_income_summary

  def calculate_monthly_income!
    assessment.assessment_errors.create!(record_id: id, record_type: self.class, error_message: converter.error_message) if converter.error?

    update!(monthly_income: converter.monthly_amount)
    converter.monthly_amount
  end

  private

  def dates_and_amounts
    Utilities::PaymentPeriodDataExtractor.call(collection: other_income_payments,
                                               date_method: :payment_date,
                                               amount_method: :amount)
  end

  def frequency
    Utilities::PaymentPeriodAnalyser.new(dates_and_amounts).period_pattern
  end

  def converter
    @converter ||= Calculators::UnearnedIncomeMonthlyConvertor.new(frequency, payment_amounts)
  end

  def payment_amounts
    other_income_payments.map(&:amount)
  end
end

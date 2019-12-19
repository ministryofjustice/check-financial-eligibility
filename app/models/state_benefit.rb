class StateBenefit < ApplicationRecord
  belongs_to :gross_income_summary
  belongs_to :state_benefit_type
  has_many :state_benefit_payments

  delegate :exclude_from_gross_income, to: :state_benefit_type

  validates :gross_income_summary_id, :state_benefit_type, presence: true

  def self.generate!(gross_income_summary, name)
    StateBenefitType.exists?(label: name) ? generate_for(gross_income_summary, name) : generate_other(gross_income_summary, name)
  end

  def self.generate_for(gross_income_summary, name)
    create!(
      gross_income_summary: gross_income_summary,
      state_benefit_type: StateBenefitType.find_by(label: name)
    )
  end

  def self.generate_other(gross_income_summary, name)
    create!(
      gross_income_summary: gross_income_summary,
      state_benefit_type: StateBenefitType.find_by(label: 'other'),
      name: name
    )
  end

  def calculate_monthly_amount!
    assessment.assessment_errors.create!(record_id: id, record_type: self.class, error_message: converter.error_message) if converter.error?

    update!(monthly_value: converter.monthly_amount)
    converter.monthly_amount
  end

  private

  def dates_and_amounts
    Utilities::PaymentPeriodDataExtractor.call(collection: state_benefit_payments,
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
    state_benefit_payments.map(&:amount)
  end
end

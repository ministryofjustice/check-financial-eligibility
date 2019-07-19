class BenefitReceipt < ApplicationRecord
  extend EnumHash
  belongs_to :assessment

  enum benefit_name: enum_hash_for(:child_benefit, :jobseekers_allowance, :universal_credit)

  validate :payment_date_cannot_be_in_future

  scope :time_series, -> { pluck(:payment_date, :amount).to_h.transform_keys(&:to_time) }

  scope :payment_pattern, -> do
    return :no_data unless time_series.present?

    analyser = PaymentPeriodAnalyser.new(time_series)
    analyser.period_pattern
  end

  def payment_date_cannot_be_in_future
    errors.add(:base, 'Benefit payment date cannot be in the future') if payment_date > Date.today
  end
end

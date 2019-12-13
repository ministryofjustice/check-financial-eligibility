module PaymentPatternConcern
  def define_payment_pattern(date_field: :payment_date, currency_field: :amount)
    scope :time_series, -> { pluck(date_field, currency_field).to_h.transform_keys(&:to_time) }

    define_singleton_method(:payment_pattern) do
      return :no_data unless time_series.present?

      Utilities::PaymentPeriodAnalyser.pattern_for time_series
    end
  end
end

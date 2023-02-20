module Utilities
  class MonthlyAmountConverter
    class << self
      def call(frequency, amount)
        calculation_method = determine_calc_method(frequency)
        send(calculation_method, amount)
      end

    private

      def determine_calc_method(frequency)
        raise ArgumentError, "unexpected frequency #{frequency}" unless frequency_conversions.key?(frequency)

        frequency_conversions[frequency]
      end

      def three_monthly_to_monthly(value)
        (value / 3).round(2)
      end

      def monthly_to_monthly(value)
        value
      end

      def four_weekly_to_monthly(value)
        (value / 4 * 52 / 12).round(2)
      end

      def two_weekly_to_monthly(value)
        (value / 2 * 52 / 12).round(2)
      end

      def weekly_to_monthly(value)
        (value * 52 / 12).round(2)
      end

      def frequency_conversions
        { three_monthly: :three_monthly_to_monthly,
          monthly: :monthly_to_monthly,
          four_weekly: :four_weekly_to_monthly,
          two_weekly: :two_weekly_to_monthly,
          weekly: :weekly_to_monthly }.with_indifferent_access
      end
    end
  end
end

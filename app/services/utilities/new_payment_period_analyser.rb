module Utilities
  class NewPaymentPeriodAnalyser
    def initialize(dates)
      @dates = dates.sort
    end

    def period_pattern
      return :weekly if RegularPeriodAnalyser.call(7, @dates) == true
      return :two_weekly if RegularPeriodAnalyser.call(14, @dates) == true
      return :four_weekly if RegularPeriodAnalyser.call(28, @dates) == true
      return :monthly if CalendarMonthlyPeriodAnalyser.call(@dates) == true

      :unknown
    end
  end
end

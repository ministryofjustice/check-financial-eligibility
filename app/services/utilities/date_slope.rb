module Utilities
  class DateSlope
    MONTH_START_CUTOFF = 10 # Days lower than this are at start of month and suitable for bumping to previous month
    BEST_MATCH_VARIANCE = 10 # If there is low variance in the range of dates, it is unlikely that they span month end

    def self.call(dates)
      new(dates).slope
    end

    attr_reader :dates

    def initialize(dates)
      @dates = dates
    end

    def slope
      1.0 * ((size * sum_xy) - (sum_x * sum_y)) / ((size * sum_xx) - (sum_x * sum_x))
    end

    def days
      @days ||= DescriptiveStatistics::Stats.new(dates.map(&:day))
    end

    def normalized_days
      @normalized_days ||= DescriptiveStatistics::Stats.new(days_at_beginning_bump_to_previous_month)
    end

    def best_match_days
      return days if days.range < BEST_MATCH_VARIANCE

      if days.standard_deviation <= normalized_days.standard_deviation
        days
      else
        normalized_days
      end
    end

    # If day is in first part of month, bump it so it effectively looks like a day in an oversized previous month
    # So 1st April looks like 32nd of March.
    # This will convert ['2-May-2019', '30-May-2019', '29-Jun-2019', '28-Jul-2019'], so that it behaves as if it was
    # ['32-Apr-2019', '30-May-2019', '29-Jun-2019', '28-Jul-2019']
    def days_at_beginning_bump_to_previous_month
      dates.map do |date|
        day = date.day
        if day > MONTH_START_CUTOFF
          day
        else
          previous_month_length = (date.beginning_of_month - 1.day).day
          day + previous_month_length
        end
      end
    end

    def coordinates
      @coordinates ||= best_match_days.each_with_index.each_with_object({}) { |(n, i), h| h[i] = n }
    end

    def sum_xy
      coordinates.sum { |x, y| x * y }
    end

    def sum_xx
      coordinates.sum { |x, _y| x * x }
    end

    def sum_x
      @sum_x ||= coordinates.sum(&:first)
    end

    def sum_y
      coordinates.sum(&:last)
    end

    def size
      @size ||= dates.size
    end
  end
end

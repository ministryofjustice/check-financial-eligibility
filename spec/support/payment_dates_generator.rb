require 'date'

# This class generates various payment frequences for all dates between RANGE_START and RANGE_END
# and writes them to a CSV fixtures file for use by the payment_period_analyser_spec.rb
#
# Usage: rake payment_periods:test_data:generate
#

class PaymentDatesGenerator
  FIXTURE_FILE = Rails.root.join('spec/fixtures/generated_payment_dates.csv')

  DateSet = Struct.new(:example_number, :period, :strategy, :dates) do
    def expected_result
      period
    end

    def to_a
      [example_number, expected_result, period, description, strategy] + dates.map { |d| d.strftime('%Y-%m-%d') }
    end

    def db_dates
      dates.map { |d| d.strftime('%Y-%m-%d') }
    end

    def description
      "#{expected_result} #{strategy} starting #{dates.first.strftime('%Y-%m-%d')}"
    end
  end

  BANK_HOLIDAYS = %w[2019-01-01 2019-04-19 2019-04-22 2019-05-06 2019-05-27 2019-08-26 2019-12-25 2019-12-26 2020-01-01].freeze
  RANGE_START = Date.new(2019, 1, 1)
  RANGE_END = Date.new(2019, 12, 31)

  attr_reader :results, :example_number

  def initialize
    @bank_holidays = BANK_HOLIDAYS.map { |bh| Date.parse(bh) }
    @example_number = 0
    @results = []
  end

  def run
    %i[monthly four_weekly two_weekly weekly].each do |period|
      start_dates.each do |start_date|
        @results << generate_date_series(period:, start_date:, holiday_strategy: :previous_working_day)
        @results << generate_date_series(period:, start_date:, holiday_strategy: :next_working_day)
      end
    end
    nil
  end

  def to_a
    @results.map(&:to_a)
  end

  def to_csv
    CSV.open(FIXTURE_FILE, 'wb') do |csv|
      csv << %w[test_number expected_result period description holiday_strategy date date date date date date date date date date date date date date date date]
      to_a.each { |line_array| csv << line_array }
    end
  end

  private

  def start_dates
    @start_dates ||= generate_start_dates
  end

  def generate_start_dates
    result = []
    (RANGE_START..RANGE_END).to_a.each do |date|
      next if weekend_or_holiday?(date)

      result << date
    end
    result
  end

  def weekend_or_holiday?(date)
    weekend?(date) || bank_holiday?(date)
  end

  def bank_holiday?(date)
    @bank_holidays.include?(date)
  end

  def weekend?(date)
    date.saturday? || date.sunday?
  end

  def generate_date_series(period:, start_date:, holiday_strategy:)
    desired_day = start_date.day
    calculation_period_end = start_date + 3.months
    dates = []
    current_date = start_date
    while current_date < calculation_period_end
      adjusted_date = weekend_or_holiday?(current_date) ? adjust_date(current_date, holiday_strategy) : current_date
      dates << adjusted_date
      current_date = advance_date(current_date, period, desired_day)
    end
    DateSet.new(@example_number += 1, period, holiday_strategy, dates)
  end

  def advance_date(date, period, desired_day)
    case period
    when :monthly
      advance_one_month(date, desired_day)
    when :four_weekly
      date + 28.days
    when :two_weekly
      date + 14.days
    when :weekly
      date + 7.days
    end
  end

  def advance_one_month(current_date, desired_day)
    current_month = current_date.month
    current_year = current_date.year
    new_month = current_month == 12 ? 1 : current_month + 1
    new_year = current_month == 12 ? current_year + 1 : current_year
    new_day = desired_or_valid_day(new_year, new_month, desired_day)
    Date.new(new_year, new_month, new_day)
  end

  def desired_or_valid_day(year, month, desired_day)
    first_day_of_month = Date.new(year, month, 1)
    last_date_in_month = first_day_of_month.end_of_month.day
    desired_day > last_date_in_month ? last_date_in_month : desired_day
  end

  def adjust_date(date, strategy)
    case strategy
    when :previous_working_day
      previous_working_day(date)
    when :next_working_day
      next_working_day(date)
    else
      raise 'Unrecognised holiday_strategy'
    end
  end

  def previous_working_day(date)
    date -= 1 while weekend?(date) || bank_holiday?(date)
    date
  end

  def next_working_day(date)
    date += 1 while weekend?(date) || bank_holiday?(date)
    date
  end
end

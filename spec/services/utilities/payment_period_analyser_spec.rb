require 'rails_helper'

module Utilities
  RSpec.describe PaymentPeriodAnalyser do
    let(:generator) { SalaryPatternGenerator }

    let(:first_day_of_month) { generator.call period: :monthly_set_day, start_at: Time.now.beginning_of_month }
    let(:first_day_of_month_weekend_offset) { generator.call period: :monthly_set_day, start_at: Time.now.beginning_of_month, day_offset: 2 }
    let(:monthly_spanning_month_end) { from_sequence '31-Jan-2019', '1-Mar-2019', '31-Mar-2019' }
    let(:monthly_with_early_next_month) { from_sequence '1-Jan-2019', '31-Jan-2019', '1-Mar-2019', '31-Mar-2019' }
    let(:twenty_eigth_of_month) { generator.call period: :monthly_set_day, start_at: Time.parse('28-jun-2019') }
    let(:twenty_eigth_of_month_weekend_offset) { generator.call period: :monthly_set_day, start_at: Time.parse('28-jul-2019'), day_offset: 2 }
    let(:monthly_by_period) { generator.call period: :monthly }
    let(:monthly_by_period_with_offset) { generator.call period: :monthly, day_offset: 2 }

    let(:monthlies) do
      {
        first_day_of_month: first_day_of_month,
        first_day_of_month_weekend_offset: first_day_of_month_weekend_offset,
        monthly_spanning_month_end: monthly_spanning_month_end,
        monthly_with_early_next_month: monthly_with_early_next_month,
        twenty_eigth_of_month: twenty_eigth_of_month,
        twenty_eigth_of_month_weekend_offset: twenty_eigth_of_month_weekend_offset,
        monthly_by_period: monthly_by_period,
        monthly_by_period_with_offset: monthly_by_period_with_offset
      }
    end

    let(:every_monday) { generator.call period: :weekly, start_at: Time.now.beginning_of_week }
    let(:midweek_with_variance) { generator.call period: :weekly, start_at: (Time.now.beginning_of_week + 2.days), day_offset: 2 }
    let(:incomplete_weekly) { every_monday.to_a.sample(10).to_h }
    let(:three_weeks) { [1, 4, 10].map { |n| every_monday.to_a[n] }.to_h }

    let(:weeklies) do
      {
        every_monday: every_monday,
        midweek_with_variance: midweek_with_variance,
        incomplete_weekly: incomplete_weekly
      }
    end

    let(:every_other_monday) { generator.call period: :two_weekly, start_at: Time.now.beginning_of_week }
    let(:midweek_fortnighly_with_variance) { generator.call period: :two_weekly, start_at: (Time.now.beginning_of_week + 2.days), day_offset: 2 }
    let(:incomplete_fortnightly) { every_other_monday.to_a.sample(5).to_h }
    let(:three_of_fortnightly) { [1, 2, 5].map { |n| every_other_monday.to_a[n] }.to_h }

    let(:fortnightlies) do
      {
        every_other_monday: every_other_monday,
        midweek_fortnighly_with_variance: midweek_fortnighly_with_variance,
        incomplete_fortnightly: incomplete_fortnightly,
        three_of_fortnightly: three_of_fortnightly
      }
    end

    let(:every_fourth_monday) { generator.call period: :four_weekly, start_at: Time.now.beginning_of_week }
    let(:midweek_four_weely_with_variance) { generator.call period: :four_weekly, start_at: (Time.now.beginning_of_week + 2.days), day_offset: 1 }
    let(:incomplete_four_weekly) { every_fourth_monday.to_a.sample(3).to_h }
    let(:four_weekly_near_month_end) { generator.call period: :four_weekly, start_at: (Time.now.end_of_month - 1.day) }
    let(:four_weely_across_month_end) { from_sequence '1-May-2019', '30-May-2019', '25-Jun-2019', '24-Jul-2019' }
    let(:incomplte_four_weekly_accross_month_end) { from_sequence '2-May-2019', '25-Jun-2019', '25-Jul-2019' }

    let(:four_weeklies) do
      {
        every_fourth_monday: every_fourth_monday,
        incomplete_four_weekly: incomplete_four_weekly,
        four_weekly_near_month_end: four_weekly_near_month_end,
        four_weely_across_month_end: four_weely_across_month_end,
        incomplte_four_weekly_accross_month_end: incomplte_four_weekly_accross_month_end
      }
    end

    let(:monthly_by_period_with_large_offset) { generator.call period: :monthly, day_offset: 4 }
    let(:incomplete_four_weekly_with_variance) { midweek_four_weely_with_variance.to_a.sample(3).to_h }
    let(:difficulties) do
      {
        monthly_by_period_with_large_offset: monthly_by_period_with_large_offset,
        incomplete_four_weekly_with_variance: incomplete_four_weekly_with_variance
      }
    end

    def message(name, analyser)
      insight = {
        days_between_dates: analyser.days_between_dates,
        size: analyser.dates.size,
        median: analyser.days_between_dates.median,
        range: analyser.days_between_dates.range,
        day_range: analyser.days.range,
        slope: analyser.date_slope
      }
      dates = analyser.dates.map { |d| d.to_s(:short) }.join(', ')
      [name, insight, dates].join("\n")
    end

    def from_sequence(*date_strings)
      date_strings.each_with_object({}) { |d, h| h[Time.parse(d)] = 10 }
    end

    def expect_all(data_set, to_be: nil, with_method: nil)
      data_set.each do |name, data|
        analyser = described_class.new(data)
        expect(analyser.__send__(with_method)).to be(to_be), message(name, analyser)
      end
    end

    context 'using dates from spreadsheets' do
      # NOTE: These tests use fixture data, and will only be run if the environment variable USE_CSV_DATA is set to 'true'.
      # This is because there are known problems whereby the PaymentPeriodAnalyser is unable to differentiate between monthly
      # and four weekly in some circumstances (mainly around February and an early Easter), and so fail.
      #
      # Set the environment variable VERBOSE to 'true' to see all tests, otherwise just failing tests will be printed.
      #
      # The two CSV files are:
      # * spec/fixtures/payment_periods.csv - this the CSV version of a hand-created spreadsheet at https://docs.google.com/spreadsheets/d/15cI-wStbejRW4qoGFwpv9tWZxK1Yq6vQ3fq74a0v154/edit#gid=0
      # * spec/fixtures/generated_payment_dates.csv - this is a file generated by the rake task 'payment_periods:test_data:generate'.  This contains automatically-generated
      #   payment dates for monthly, four_weekly, two_weekly and weekly for every working day in 2018, with strategies of using the
      #   previous working day, or the next working day when the
      #   payment date falls on a bank holiday
      #

      reason = 'Tests against CSV data are skipped because of known faults distiguishing  between monthly and four_weekly around Easter'
      options = ENV['USE_CSV_DATA'] == 'true' ? {} : { skip: reason }

      it 'should pass all tests on the hand-written date spreadsheet', options do
        filename = Rails.root.join('spec/fixtures/payment_periods.csv')
        num_failed_tests = read_and_check_results(filename)
        expect(num_failed_tests).to be_zero, "#{num_failed_tests} failing tests using CSV data from #{filename}"
      end

      it 'should pass all tests on the file generated by PaymenDatesGenerator', options do
        filename = Rails.root.join('spec/fixtures/generated_payment_dates.csv')
        num_failed_tests = read_and_check_results(filename)
        expect(num_failed_tests).to be_zero, "#{num_failed_tests} failing tests using CSV data from #{filename}"
      end

      def read_and_check_results(fixture_file) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        num_failed_tests = 0
        CSV.read(fixture_file).each do |fields|
          next if fields.first == 'Version number'
          next if fields.first == 'test_number'

          test_number = fields.shift
          expected_result = fields.shift
          _period = fields.shift
          test_name = fields.shift
          _holiday_strategy = fields.shift
          dates = fields.compact.map { |d| Date.parse(d) }
          date_salaries = dates.map { |d| [d, nil] }.to_h
          puts ">>>>>>>>>>>>  #{__FILE__}:#{__LINE__} <<<<<<<<<<<<\n"
          actual_result = described_class.pattern_for(date_salaries).to_s
          successful_test = actual_result == expected_result
          colour = successful_test ? :green : :red
          num_failed_tests += 1 unless successful_test
          next unless verbose? || !successful_test

          puts "#{test_number} #{test_name}".colorize(colour)
          puts format('   expected: %<expected>12s, got: %<actual>s', expected: expected_result, actual: actual_result).colorize(colour)
          puts "    #{dates.map { |d| d.strftime('%Y-%m-%d') }.join(', ')} " unless successful_test
        end
        num_failed_tests
      end

      def verbose?
        ENV['VERBOSE'] == 'true'
      end
    end

    context 'individual tests' do
      let(:dates) { string_dates.map { |d| [Date.parse(d), nil] }.to_h }

      context 'Every two weeks on a Monday but paid on Friday before bank holiday (middle payment)' do
        let(:string_dates) { '2019-03-4, 2019-03-18, 2019-04-01, 2019-04-12, 2019-04-29, 2019-05-13, 2019-05-27, 2019-06-10'.split(', ') }
        it 'returns two_weekly using #period_pattern' do
          expect(described_class.new(dates).period_pattern).to eq :two_weekly
        end

        it 'retursn two_weekly using .pattern_for' do
          expect(described_class.pattern_for(dates)).to eq :two_weekly
        end
      end

      context 'Monthly on the last working day around Christmas,  but paid on 20th December (middle payment)' do
        let(:string_dates) { '2019-11-29, 2019-12-20, 2020-01-31'.split(', ') }
        it 'returns two_weekly' do
          expect(described_class.new(dates).period_pattern).to eq :unknown
        end
      end

      context 'every four weeks on a monday, but paid on Friday preceeding May bank holiday' do
        let(:string_dates) { '2019-03-11, 2019-04-08, 2019-05-03, 2019-06-03'.split(', ') }
        it 'returns four_weekly' do
          expect(described_class.new(dates).period_pattern).to eq :four_weekly
        end
      end

      context 'monthly falling on Easter Monday' do
        # NOTE: This always returns monthly because there are 29 days between 21 Feb and 21 March, and also 28 days between
        # 21 March and the day before Good Friday - 18th April
        #
        let(:string_dates) { '2019-02-21, 2019-03-21, 2019-04-18'.split(', ') }
        it 'returns monthly', skip: 'Skipped because the test data is generated randomly, and sometimes PaymentPeriodAnalyser is unable to correctly get the correct period' do
          expect(described_class.new(dates).period_pattern).to eq :monthly
        end
      end

      context 'every two weeks' do
        let(:string_dates) { '2019-05-15, 2019-05-01, 2019-04-17, 2019-04-03'.split(', ') }
        it 'returns two-weekly' do
          expect(described_class.new(dates).period_pattern).to eq :two_weekly
        end
      end

      context 'irregular payments' do
        context 'just one payment' do
          let(:string_dates) { ['2019-05-15'] }
          it 'returns unknown' do
            expect(described_class.new(dates).period_pattern).to eq :unknown
          end
        end

        context 'two payments 10 days apart' do
          let(:string_dates) { '2019-05-15, 2019-05-25'.split(', ') }
          it 'returns unknown' do
            expect(described_class.new(dates).period_pattern).to eq :unknown
          end
        end
      end
    end

    describe '#period_pattern' do
      let(:time_series) { first_day_of_month }
      subject { described_class.new(time_series).period_pattern }

      it 'returns matching label' do
        expect(subject).to eq(:monthly)
      end
    end

    describe '.monthly?' do
      # TODO: This test fails randomly.  Needs to be re-written with precise dates fix this
      it 'returns true for each monthly',
         skip: 'Skipped because the test data is generated randomly, and sometimes PaymentPeriodAnalyser is unable to correctly get the correct period' do
        expect_all(monthlies, to_be: true, with_method: :monthly?)
      end

      it 'returns false for each weekly' do
        expect_all(weeklies, to_be: false, with_method: :monthly?)
      end

      it 'returns false for each fortnightly' do
        expect_all(fortnightlies, to_be: false, with_method: :monthly?)
      end

      it 'returns false for each four weekly' do
        expect_all(four_weeklies, to_be: false, with_method: :monthly?)
      end
    end

    describe '#weekly?' do
      it 'returns false for each monthly' do
        expect_all(monthlies, to_be: false, with_method: :weekly?)
      end

      it 'returns true for each weekly' do
        expect_all(weeklies, to_be: true, with_method: :weekly?)
      end

      it 'returns false for each fortnightly' do
        expect_all(fortnightlies, to_be: false, with_method: :weekly?)
      end

      it 'returns false for each four weekly' do
        expect_all(four_weeklies, to_be: false, with_method: :weekly?)
      end

      # TODO: This test fails randomly.  Needs to be re-written with preceise dates fix this
      it 'returns false for difficulties',
         skip: 'Skipped because the test data is generated randomly, and sometimes PaymentPeriodAnalyser is unable to correctly get the correct period' do
        expect_all(difficulties, to_be: false, with_method: :weekly?)
      end
    end

    describe '#two_weekly?' do
      it 'returns false for each monthly' do
        expect_all(monthlies, to_be: false, with_method: :two_weekly?)
      end

      it 'returns false for each weekly' do
        expect_all(weeklies, to_be: false, with_method: :two_weekly?)
      end

      it 'returns true for each fortnightly' do
        expect_all(fortnightlies, to_be: true, with_method: :two_weekly?)
      end

      it 'returns false for each four weekly' do
        expect_all(four_weeklies, to_be: false, with_method: :two_weekly?)
      end
    end

    describe '#four_weekly?' do
      it 'returns false for each monthly' do
        expect_all(monthlies, to_be: false, with_method: :four_weekly?)
      end

      it 'returns false for each weekly' do
        expect_all(weeklies, to_be: false, with_method: :four_weekly?)
      end

      it 'returns false for each fortnightly' do
        expect_all(fortnightlies, to_be: false, with_method: :four_weekly?)
      end

      it 'returns true for each four weekly' do
        expect_all(four_weeklies, to_be: true, with_method: :four_weekly?)
      end
    end
  end
end

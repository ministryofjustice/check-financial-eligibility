require 'rails_helper'

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
      incomplete_weekly: incomplete_weekly,
      three_weeks: three_weeks
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
      midweek_four_weely_with_variance: midweek_four_weely_with_variance,
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

  def message(name, analyser) # rubocop:disable Metrics/AbcSize
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

  describe '#period_pattern' do
    let(:time_series) { first_day_of_month }
    subject { described_class.new(time_series).period_pattern }

    it 'returns matching label' do
      expect(subject).to eq(:monthly)
    end
  end

  describe '.monthly?' do
    # TODO: This test fails randomly.  Needs to be re-written with preceise dates fix this
    xit 'returns true for each monthly' do
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
    xit 'returns false for difficulties' do
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

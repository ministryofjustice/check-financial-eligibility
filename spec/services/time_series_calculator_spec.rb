require 'rails_helper'

describe TimeSeriesCalculator do
  let(:salary) { 100 }
  let(:period) { :monthly }
  let(:salary_offset) { nil }
  let(:variance) { {} }
  let(:payments) do
    SalaryPatternGenerator.call(
      period: period,
      salary: salary,
      salary_offset: salary_offset
    ).merge(variance)
  end

  subject { described_class.new(payments) }

  describe '#mean' do
    it 'returns the average' do
      expect(subject.mean).to eq(salary)
    end
  end

  describe '#standard_deviation' do
    it 'returns zero if no variance' do
      expect(subject.standard_deviation).to eq(0)
    end

    context 'with variance values' do
      let(:variance) { { 1.week.ago => (salary - 2) } }
      it 'returns a number greater than zero' do
        expect(subject.standard_deviation).to be_between(0, 2).exclusive
      end
    end
  end

  describe '#average_days_between_dates' do
    it 'returns a number near the length of a month' do
      expect(subject.average_days_between_dates).to be_between(27, 31).inclusive
    end

    context 'with weekly data' do
      let(:period) { :weekly }

      it 'returns 7' do
        expect(subject.average_days_between_dates).to eq(7)
      end
    end
  end

  describe '#deviation_between_dates' do
    it 'returns a value less that 3 as range is between 27 and 31' do
      expect(subject.deviation_between_dates).to be < 3
    end

    context 'with a regular pattern' do
      let(:period) { :weekly }
      it 'returns zerodeviation' do
        expect(subject.deviation_between_dates).to be_zero
      end
    end
  end

  describe '#latest_value' do
    let(:latest_value) { Faker::Number.normal(50, 10) }
    let(:variance) { { 1.week.from_now => latest_value } }
    it 'returns that latest value' do
      expect(subject.latest_value).to eq(latest_value)
    end
  end

  describe '#max_variance' do
    let(:salary_offset) { 20 }
    let(:max) { payments.values.max }
    let(:min) { payments.values.min }
    it 'is the value between max and min' do
      expect(subject.max_variance).to eq(max - min)
    end
  end
end

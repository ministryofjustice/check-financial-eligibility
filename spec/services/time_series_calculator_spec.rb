require 'rails_helper'

describe TimeSeriesCalculator do
  let(:salary) { 100 }
  let(:period) { :monthly }
  let(:payments) do
    SalaryPatternGenerator.call(
      period: period,
      salary: salary
    )
  end

  subject { described_class.new(payments) }

  describe '#mean' do
    it 'returns the average' do
      expect(subject.mean).to eq(salary)
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
end

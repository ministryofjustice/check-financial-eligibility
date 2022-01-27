require 'rails_helper'

module Utilities
  describe CalculationPeriod do
    let(:period) { described_class.new(submission_date) }

    describe '#period_start' do
      context '31 May' do
        let(:submission_date) { Date.new(2019, 5, 31) }

        it 'is 28th Feb' do
          expect(period.period_start).to eq Date.new(2019, 2, 28)
        end
      end

      context '29 May' do
        let(:submission_date) { Date.new(2019, 5, 29) }

        it 'is 28th Feb' do
          expect(period.period_start).to eq Date.new(2019, 2, 28)
        end
      end
    end

    describe 'period_end' do
      context '31 May' do
        let(:submission_date) { Date.new(2019, 5, 31) }

        it 'is 30th May' do
          expect(period.period_end).to eq Date.new(2019, 5, 30)
        end
      end

      context '1st Jan' do
        let(:submission_date) { Date.new(2019, 1, 1) }

        it 'is 31st Dec' do
          expect(period.period_end).to eq Date.new(2018, 12, 31)
        end
      end
    end

    describe 'contains?' do
      let(:submission_date) { Date.new(2019, 5, 29) }

      context 'before start date' do
        it 'is false' do
          expect(period.contains?(Time.zone.local(2019, 2, 27))).to be false
        end
      end

      context 'on start date' do
        it 'is true' do
          expect(period.contains?(Time.zone.local(2019, 2, 28, 5, 0, 0))).to be true
        end
      end

      context 'in middle of period' do
        it 'is true' do
          expect(period.contains?(Time.zone.local(2019, 4, 15, 5, 0, 0))).to be true
        end
      end

      context 'on end date' do
        it 'is true' do
          expect(period.contains?(Time.zone.local(2019, 5, 28, 22, 10, 0))).to be true
        end
      end

      context 'after end date' do
        it 'is false' do
          expect(period.contains?(Time.zone.local(2019, 5, 29, 5, 0, 0))).to be false
        end
      end
    end
  end
end

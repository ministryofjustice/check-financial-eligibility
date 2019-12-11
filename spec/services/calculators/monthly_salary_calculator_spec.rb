require 'rails_helper'

module Calculators
  describe MonthlySalaryCalculator do
    let(:salary) { 100 }
    let(:period_type) { :weekly }
    let(:salary_offset) { nil }
    let(:variance) { {} }
    let(:payments) do
      SalaryPatternGenerator.call(
        period: period_type,
        salary: salary,
        salary_offset: salary_offset
      ).merge(variance)
    end
    let(:weeks_in_year) { 52 }
    let(:months_in_year) { 12.0 }
    let(:average) { payments.values.sum(0.0) / payments.values.size }
    let(:last_payment) { payments.values.first }

    subject { described_class.new(time_series: payments, period_type: period_type) }

    describe '#monthly_equivalent' do
      it 'is salary multiplied by number of weeks, divided by number of months' do
        expect(subject.monthly_equivalent).to eq(salary * weeks_in_year / months_in_year)
      end

      context 'with salary variance' do
        let(:salary_offset) { 10 }

        it 'is average multiplied by number of weeks, divided by number of months' do
          expect(subject.monthly_equivalent).to eq(average * weeks_in_year / months_in_year)
        end
      end

      context 'monthly' do
        let(:period_type) { :monthly }

        it 'returns the salary' do
          expect(subject.monthly_equivalent).to eq(salary)
        end

        context 'with small salary variance' do
          let(:salary_offset) { 10 }

          it 'returns the last entry' do
            expect(subject.monthly_equivalent).to eq(last_payment)
          end
        end

        context 'with large salary variance' do
          let(:variance) { { 1.month.from_now => (salary + described_class::NORMAL_VARIANCE_THRESHOLD + 1) } }

          it 'returns the average' do
            expect(subject.monthly_equivalent).to eq(average)
          end
        end
      end

      context 'two_weekly' do
        let(:period_type) { :two_weekly }

        it 'is half salary multiplied by number of weeks, divided by number of months' do
          expect(subject.monthly_equivalent).to eq((salary / 2.0) * weeks_in_year / months_in_year)
        end

        context 'with salary variance' do
          let(:salary_offset) { 30 }

          it 'is half average multiplied by number of weeks, divided by number of months' do
            expect(subject.monthly_equivalent).to eq((average / 2.0) * weeks_in_year / months_in_year)
          end
        end
      end

      context 'four_weekly' do
        let(:period_type) { :four_weekly }

        it 'is half salary multiplied by number of weeks, divided by number of months' do
          expect(subject.monthly_equivalent).to eq((salary / 4.0) * weeks_in_year / months_in_year)
        end

        context 'with salary variance' do
          let(:salary_offset) { 30 }

          it 'is half average multiplied by number of weeks, divided by number of months' do
            expect(subject.monthly_equivalent).to eq((average / 4.0) * weeks_in_year / months_in_year)
          end
        end
      end

      context 'unknown period type' do
        let(:period_type) { :unknown }
        let(:payments) { { Time.now => salary } }
        it 'raises an error' do
          expect { subject.monthly_equivalent }.to raise_error(MonthlySalaryCalculator::PeriodError)
        end
      end
    end

    describe '.call' do
      subject { described_class.call(time_series: payments, period_type: period_type) }

      it 'returns the monthly equivalent for the data' do
        expect(subject).to eq(salary * weeks_in_year / months_in_year)
      end
    end
  end
end

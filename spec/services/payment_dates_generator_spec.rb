require 'rails_helper'
require_relative '../support/payment_dates_generator'

describe PaymentDatesGenerator do
  describe 'private method #advance_one_month' do
    subject { described_class.new.__send__(:advance_one_month, date, desired_day).strftime('%Y-%m-%d') }
    let(:date) { Date.parse(date_string) }
    let(:desired_day) { date.day }

    context 'normal mid month date' do
      let(:date_string) { '2018-02-15' }
      it 'returns the same day in the following month' do
        expect(subject).to eq '2018-03-15'
      end
    end

    context 'last day of month when following month has same number of days' do
      let(:date_string) { '2018-07-31' }
      it 'returns the same day in the following month' do
        expect(subject).to eq '2018-08-31'
      end
    end

    context 'last day of month when following month has fewer days' do
      let(:date_string) { '2018-01-31' }
      it 'returns the last day in the following month' do
        expect(subject).to eq '2018-02-28'
      end
    end

    context 'mid-december' do
      let(:date_string) { '2018-12-15' }
      it 'returns the same day in the january of the next year' do
        expect(subject).to eq '2019-01-15'
      end
    end

    context 'end of december' do
      let(:date_string) { '2018-12-31' }
      it 'returns the same day in the january of the next year' do
        expect(subject).to eq '2019-01-31'
      end
    end
  end

  describe 'private methods #generate_date_series(period:, start_date:, holiday_strategy:)' do
    let(:generator) { described_class.new }
    let(:date) { Date.parse(date_text) }

    subject do
      generator = described_class.new
      date_set = generator.__send__(:generate_date_series, period: period, start_date: date, holiday_strategy: strategy)
      date_set.db_dates
    end

    context 'monthly' do
      let(:period) { :monthly }

      context 'strategy: previous working day' do
        let(:strategy) { :previous_working_day }

        context 'starting 2019-01-02' do
          let(:date_text) { '2019-01-02' }

          it 'generates the series' do
            expect(subject).to eq(%w[2019-01-02 2019-02-01 2019-03-01])
          end
        end

        context 'starting 2019-02-21' do
          let(:date_text) { '2019-02-21' }
          it 'generates the series avoiding Good Friday' do
            expect(subject).to eq(%w[2019-02-21 2019-03-21 2019-04-18])
          end
        end
      end
    end

    context 'four_weekly' do
      let(:period) { :four_weekly }

      context 'strategy: previous working day' do
        let(:strategy) { :previous_working_day }

        context '2019-03-11, 2019-04-08, 2019-05-03, 2019-06-03' do
          let(:date_text) { '2019-03-11' }

          it 'generates the series' do
            expect(subject).to eq(%w[2019-03-11 2019-04-08 2019-05-03 2019-06-03])
          end
        end
      end
    end
  end
end

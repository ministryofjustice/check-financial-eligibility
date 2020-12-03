require 'rails_helper'

RSpec.describe DateValidator do
  let(:params_description) { Faker::Commerce.product_name.underscore }
  let(:option) { nil }

  subject { described_class.new(params_description, option) }

  describe '#validate' do
    it 'returns true with a valid date' do
      ['10-Jun-2015', '10-06-2111', 3.days.ago.to_date.to_s, 3.days.from_now.to_date.to_s].each do |input|
        expect(subject.validate(input)).to be_truthy
      end
    end

    it 'returns false with an invalid date' do
      %w[10-Jon-2015 26-26-2019 foo].each do |input|
        expect(subject.validate(input)).to be_falsey
      end
    end

    context 'with today_or_older option' do
      let(:option) { :today_or_older }

      it 'returns true for today' do
        input = Date.today.to_s
        expect(subject.validate(input)).to be_truthy
      end

      it 'returns true for date in past' do
        input = 2.days.ago.to_s
        expect(subject.validate(input)).to be_truthy
      end

      it 'returns false for date in future' do
        input = 2.days.from_now.to_s
        expect(subject.validate(input)).to be_falsey
      end
    end

    context 'with submission_date_today_or_older option' do
      let(:option) { :submission_date_today_or_older }

      before { allow(Rails.configuration.x.application).to receive(:allow_future_submission_date).and_return false }

      it 'returns true for today' do
        input = Date.today.to_s
        expect(subject.validate(input)).to be_truthy
      end

      it 'returns true for date in past' do
        input = 2.days.ago.to_s
        expect(subject.validate(input)).to be_truthy
      end

      it 'returns false for date in future' do
        input = 2.days.from_now.to_s
        expect(subject.validate(input)).to be_falsey
      end

      context 'allow submission date to be future is configured to true' do
        before { allow(Rails.configuration.x.application).to receive(:allow_future_submission_date).and_return true }

        it 'returns true for date in future' do
          input = 2.days.from_now.to_s
          expect(subject.validate(input)).to be_truthy
        end
      end
    end

    context 'with unknown option' do
      let(:option) { :unknown }

      it 'raises and error' do
        expect { subject.validate(Date.today.to_s) }.to raise_error("date option 'unknown' not recognised")
      end
    end
  end
end

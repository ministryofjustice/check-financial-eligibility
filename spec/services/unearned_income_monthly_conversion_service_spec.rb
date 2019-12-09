require 'rails_helper'

RSpec.describe UnearnedIncomeMonthlyConversionService do
  subject { described_class.new(frequency, payments) }

  let(:payments) { [203.44, 205.00, 205.00] }

  context 'monthly' do
    let(:frequency) { :monthly }
    describe 'error?' do
      it 'returns false' do
        expect(subject.error?).to be false
      end
    end

    describe 'monthly_amount' do
      it 'returns the average monthly amount' do
        subject.error?
        expect(subject.monthly_amount).to eq 204.48
      end
    end
  end

  context 'four_weekly' do
    let(:frequency) { :four_weekly }
    describe 'error?' do
      it 'returns false' do
        expect(subject.error?).to be false
      end
    end

    describe 'monthly_amount' do
      it 'returns the average for the calendar month' do
        subject.error?
        expect(subject.monthly_amount).to eq 221.52
      end
    end
  end

  context 'two_weekly' do
    let(:frequency) { :two_weekly }
    describe 'error?' do
      it 'returns false' do
        expect(subject.error?).to be false
      end
    end

    describe 'monthly_amount' do
      it 'returns the average for the calendar month' do
        subject.error?
        expect(subject.monthly_amount).to eq 443.04
      end
    end
  end

  context 'weekly' do
    let(:frequency) { :weekly }
    describe 'error?' do
      it 'returns false' do
        expect(subject.error?).to be false
      end
    end

    describe 'monthly_amount' do
      it 'returns the average for the calendar month' do
        subject.error?
        expect(subject.monthly_amount).to eq 886.08
      end
    end
  end

  context 'unknown' do
    let(:frequency) { :unknown }
    describe 'error?' do
      it 'returns true' do
        expect(subject.error?).to be true
      end
    end

    describe 'error_message' do
      it 'returns error message' do
        subject.error?
        expect(subject.error_message).to eq :unknown_payment_frequency
      end
    end

    describe 'monthly_amount' do
      it 'returns nil' do
        subject.error?
        expect(subject.monthly_amount).to be_nil
      end
    end
  end
end

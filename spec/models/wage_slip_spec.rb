require 'rails_helper'

RSpec.describe WageSlip, type: :model do
  let!(:dates) { [4, 8, 12, 16].map { |n| n.weeks.ago } }
  let(:assessment) { create :assessment }
  let!(:wage_slips) do
    dates.map { |date| create :wage_slip, payment_date: date, assessment: assessment }
  end
  let(:time_series) do
    wage_slips.each_with_object({}) { |w, h| h[w.payment_date.to_time] = w.gross_pay }
  end

  describe 'time_series' do
    it 'matches expected time series' do
      expect(assessment.wage_slips.time_series).to eq(time_series)
    end
  end

  describe 'payment_period' do
    it 'matches date pattern' do
      expect(assessment.wage_slips.payment_pattern).to eq(:four_weekly)
    end

    context 'with weekly dates' do
      let!(:dates) { (1..14).map { |n| n.weeks.ago } }

      it 'returns :weekly' do
        expect(assessment.wage_slips.payment_pattern).to eq(:weekly)
      end
    end

    context 'with two weekly dates' do
      let!(:dates) { (1..14).step(2).map { |n| n.weeks.ago } }

      it 'returns :two_weekly' do
        expect(assessment.wage_slips.payment_pattern).to eq(:two_weekly)
      end
    end

    context 'with monthly dates' do
      let!(:dates) { (1..3).map { |n| n.months.ago } }

      it 'returns :monthly' do
        expect(assessment.wage_slips.payment_pattern).to eq(:monthly)
      end
    end

    context 'with odd weekly dates' do
      let!(:dates) { [2.months.ago, 15.days.ago] }

      it 'returns :unknown' do
        expect(assessment.wage_slips.payment_pattern).to eq(:unknown)
      end
    end

    context 'with no benefit receipts' do
      let!(:wage_slips) { nil }

      it 'returns nil' do
        expect(assessment.wage_slips.payment_pattern).to eq(:no_data)
      end
    end
  end
end

require "rails_helper"

module Utilities
  RSpec.describe PaymentPeriodAnalyser do
    describe ".call" do
      let(:dates) { %w[dummy_date_1 dummy_date_2 dummy_date_3] }

      it "returns weekly" do
        allow(RegularPeriodAnalyser).to receive(:call).with(7, dates).and_return true
        expect(RegularPeriodAnalyser).to receive(:call).with(7, dates)
        expect(RegularPeriodAnalyser).not_to receive(:call).with(14, dates)
        expect(RegularPeriodAnalyser).not_to receive(:call).with(28, dates)
        expect(CalendarMonthlyPeriodAnalyser).not_to receive(:call).with(dates)

        expect(described_class.new(dates).period_pattern).to eq :weekly
      end

      it "returns two_weekly" do
        allow(RegularPeriodAnalyser).to receive(:call).with(7, dates).and_return false
        expect(RegularPeriodAnalyser).to receive(:call).with(7, dates)
        allow(RegularPeriodAnalyser).to receive(:call).with(14, dates).and_return true
        expect(RegularPeriodAnalyser).to receive(:call).with(14, dates)
        expect(RegularPeriodAnalyser).not_to receive(:call).with(28, dates)
        expect(CalendarMonthlyPeriodAnalyser).not_to receive(:call).with(dates)

        expect(described_class.new(dates).period_pattern).to eq :two_weekly
      end

      it "returns four_weekly" do
        allow(RegularPeriodAnalyser).to receive(:call).with(7, dates).and_return false
        expect(RegularPeriodAnalyser).to receive(:call).with(7, dates)
        allow(RegularPeriodAnalyser).to receive(:call).with(14, dates).and_return false
        expect(RegularPeriodAnalyser).to receive(:call).with(14, dates)
        allow(RegularPeriodAnalyser).to receive(:call).with(28, dates).and_return true
        expect(RegularPeriodAnalyser).to receive(:call).with(28, dates)
        expect(CalendarMonthlyPeriodAnalyser).not_to receive(:call).with(dates)

        expect(described_class.new(dates).period_pattern).to eq :four_weekly
      end

      it "returns monthly" do
        allow(RegularPeriodAnalyser).to receive(:call).with(7, dates).and_return false
        allow(RegularPeriodAnalyser).to receive(:call).with(14, dates).and_return false
        allow(RegularPeriodAnalyser).to receive(:call).with(28, dates).and_return false
        allow(CalendarMonthlyPeriodAnalyser).to receive(:call).with(dates).and_return true
        expect(RegularPeriodAnalyser).to receive(:call).with(7, dates)
        expect(RegularPeriodAnalyser).to receive(:call).with(14, dates)
        expect(RegularPeriodAnalyser).to receive(:call).with(28, dates)
        expect(CalendarMonthlyPeriodAnalyser).to receive(:call).with(dates)

        expect(described_class.new(dates).period_pattern).to eq :monthly
      end

      it "returns unknown" do
        allow(RegularPeriodAnalyser).to receive(:call).with(7, dates).and_return false
        allow(RegularPeriodAnalyser).to receive(:call).with(14, dates).and_return false
        allow(RegularPeriodAnalyser).to receive(:call).with(28, dates).and_return false
        allow(CalendarMonthlyPeriodAnalyser).to receive(:call).with(dates).and_return false
        expect(RegularPeriodAnalyser).to receive(:call).with(7, dates)
        expect(RegularPeriodAnalyser).to receive(:call).with(14, dates)
        expect(RegularPeriodAnalyser).to receive(:call).with(28, dates)
        expect(CalendarMonthlyPeriodAnalyser).to receive(:call).with(dates)

        expect(described_class.new(dates).period_pattern).to eq :unknown
      end
    end
  end
end

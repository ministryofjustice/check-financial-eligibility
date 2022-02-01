require "rails_helper"

module Utilities
  RSpec.describe RegularPeriodAnalyser do
    let(:bank_holidays) { %w[2019-07-09 2019-07-16 2019-07-23] }

    subject(:analyser) { described_class.call(period, dates) }

    before do
      BankHoliday.create!(dates: bank_holidays)
    end

    context "every 7 days" do
      let(:period) { 7 }

      context "regular weekly intervals" do
        let(:dates) { regular_weekly_dates }

        it "returns true" do
          expect(analyser).to be true
        end
      end

      context "too few dates" do
        let(:dates) { not_enough_weekly_dates }

        it "returns false" do
          expect(analyser).to be false
        end
      end

      context "not regular weekly intervals" do
        let(:dates) { not_regular_weekly_intervals }

        it "returns false" do
          expect(analyser).to be false
        end
      end

      context "bank holiday in middle of range" do
        let(:bank_holidays) { make_dates(%w[2020-08-05 2020-08-06 2020-08-07]) }

        context "payment is made day before bank holiday" do
          let(:dates) { weekly_payments_paid_before_bank_holiday }

          it "returns true" do
            expect(analyser).to be true
          end
        end

        context "payment is made day after bank holiday" do
          let(:dates) { weekly_payments_paid_after_bank_holiday }

          it "returns true" do
            expect(analyser).to be true
          end
        end
      end

      context "bank holiday at start of range" do
        let(:bank_holidays) { make_dates(%w[2020-07-09 2020-07-10]) }
        # first date 8th, bank holiday 9th ^, second payment date 16th
        # sometimes people get paid the 'day before' a bank holiday
        # sometimes people get paid the 'day after' a bank holiday

        # ---
        # The second bank holiday 10th falls in between two payment dates, 6th and 13th...
        # the 13th is 7 days after 6th. will the paid date be affected by the bankholiday in between??
        context "payment is made day before bank holiday" do
          let(:dates) { weekly_payments_paid_before_bank_holiday_at_start }

          it "returns true" do
            expect(analyser).to be true
          end
        end

        context "payment is made after the weekend following bank holiday" do
          let(:dates) { weekly_payments_paid_after_bank_holiday_at_start }

          it "returns true" do
            expect(analyser).to be true
          end
        end
      end

      context "bank_holiday at end of range" do
        let(:bank_holidays) { make_dates(%w[2020-07-09 2020-09-24]) }

        context "payment is made day before bank holiday" do
          let(:dates) { weekly_payments_paid_before_bank_holiday_at_end }

          it "returns true" do
            expect(analyser).to be true
          end
        end

        context "payment is made day after bank holiday" do
          let(:dates) { weekly_payments_paid_after_bank_holiday_at_end }

          it "returns true" do
            expect(analyser).to be true
          end
        end
      end
    end

    context "every 28 days" do
      let(:period) { 28 }

      context "regular 28 day intervals" do
        let(:dates) { make_dates(%w[2020-07-09 2020-08-06 2020-09-03]) }

        it "returns true" do
          expect(analyser).to be true
        end
      end

      context "irregular period" do
        let(:dates) { make_dates(%w[2020-07-10 2020-08-06 2020-09-03]) }

        it "returns false" do
          expect(analyser).to be false
        end
      end

      context "28 day period with bank holidays at start of date range" do
        let(:bank_holidays) { make_dates(%w[2020-07-09 2020-09-24]) }

        context "first date paid early because of holiday" do
          let(:dates) { make_dates(%w[2020-07-08 2020-08-06 2020-09-03]) }

          it "returns true" do
            expect(analyser).to be true
          end
        end

        context "first date paid late because of holiday" do
          let(:dates) { make_dates(%w[2020-07-10 2020-08-06 2020-09-03]) }

          it "returns true" do
            expect(analyser).to be true
          end
        end
      end

      context "28 day period with bank holidays in middle of date range" do
        let(:bank_holidays) { make_dates(%w[2020-08-06 2020-09-24]) }

        context "first date paid early because of holiday" do
          let(:dates) { make_dates(%w[2020-07-09 2020-08-05 2020-09-03]) }

          it "returns true" do
            expect(analyser).to be true
          end
        end

        context "first date paid late because of holiday" do
          let(:dates) { make_dates(%w[2020-07-09 2020-08-07 2020-09-03]) }

          it "returns true" do
            expect(analyser).to be true
          end
        end
      end
    end

    def make_dates(array_of_string_dates)
      array_of_string_dates.map { |x| Date.parse(x) }
    end

    def four_weekly_payments
      make_dates(%w[2020-07-09 2020-08-06 2020-09-03])
    end

    def regular_weekly_dates
      make_dates(%w[
        2020-07-09
        2020-07-16
        2020-07-23
        2020-07-30
        2020-08-06
        2020-08-13
        2020-08-20
        2020-08-27
        2020-09-03
        2020-09-10
        2020-09-17
        2020-09-24
      ])
    end

    def not_enough_weekly_dates
      regular_weekly_dates.slice(0, 10)
    end

    def not_regular_weekly_intervals
      dates = regular_weekly_dates
      dates[1] = Date.parse "2020-07-11"
      dates
    end

    def weekly_payments_paid_before_bank_holiday
      dates = regular_weekly_dates
      dates[4] = Date.parse "2020-08-04"
      dates
    end

    def weekly_payments_paid_after_bank_holiday
      dates = regular_weekly_dates
      dates[4] = Date.parse "2020-08-10"
      dates
    end

    def weekly_payments_paid_before_bank_holiday_at_start
      dates = regular_weekly_dates
      dates[0] = Date.parse "2020-07-08"
      dates
    end

    def weekly_payments_paid_after_bank_holiday_at_start
      dates = regular_weekly_dates
      dates[0] = Date.parse "2020-07-13"
      dates
    end

    def weekly_payments_paid_before_bank_holiday_at_end
      dates = regular_weekly_dates
      dates[11] = Date.parse "2020-09-23"
      dates
    end

    def weekly_payments_paid_after_bank_holiday_at_end
      dates = regular_weekly_dates
      dates[11] = Date.parse("2020-09-25")
      dates
    end
  end
end

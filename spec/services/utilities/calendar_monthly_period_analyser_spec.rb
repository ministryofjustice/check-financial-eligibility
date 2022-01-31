require "rails_helper"

module Utilities
  RSpec.describe CalendarMonthlyPeriodAnalyser do
    describe ".call" do
      let(:bank_holidays) { make_dates(%w[2019-07-09 2019-07-16 2019-07-23]) }

      before {  BankHoliday.create!(dates: bank_holidays) }

      subject { described_class.call(dates) }

      context "no bank holidays interfere with date sequence" do
        context "too few dates" do
          let(:dates) { make_dates(%w[2020-03-15 2020-04-15]) }

          it "returns false" do
            expect(subject).to be false
          end
        end

        context "regular dates each month" do
          let(:dates) { make_dates(%w[2020-03-03 2020-04-03 2020-05-03]) }

          it "returns true" do
            expect(subject).to be true
          end
        end

        context "irregular dates" do
          let(:dates) { make_dates(%w[2020-03-03 2020-04-05 2020-05-01]) }

          it "returns false" do
            expect(subject).to be false
          end
        end

        context "payment at end of month" do
          context "always last day of month" do
            let(:dates) { make_dates(%w[2019-01-31 2019-02-28 2019-03-31]) }

            it "returns true" do
              expect(subject).to be true
            end
          end

          context "last day of month falls on a weekend" do
            let(:dates) { make_dates(%w[2020-01-31 2020-02-28 2020-03-31]) }

            it "allows payment on Fri 28 Feb instead of Sat 29th" do
              expect(subject).to be true
            end
          end
        end
      end

      context "weekends cause change in payment date" do
        context "in middle of sequence" do
          context "middle payment date would have been Sunday" do
            # would have been paid on the Fri 3rd April, Sunday 3rd May, Wed 3rd June of every month
            context "paid early" do
              let(:dates) { make_dates(%w[2020-04-03 2020-05-01 2020-06-03]) }

              it "is true" do
                expect(subject).to be true
              end
            end

            context "paid late" do
              let(:dates) { make_dates(%w[2020-04-03 2020-05-04 2020-06-03]) }

              it "is true" do
                expect(subject).to be true
              end
            end
          end

          context "middle payment date would have been Saturday, last Sunday" do
            # would have been Wed 1st Jan, Sat 1st Feb, Sun 1st Mar
            context "paid early" do
              let(:dates) { make_dates(%w[2020-01-01 2020-01-31 2020-02-28]) }

              it "is true" do
                expect(subject).to be true
              end
            end

            context "paid late" do
              let(:dates) { make_dates(%w[2020-01-01 2020-02-03 2020-03-02]) }

              it "is true" do
                expect(subject).to be true
              end
            end
          end
        end

        context "at end of sequence" do
          context "last payment date would have been Saturday" do
            # would have been paid on Tue 3rd Mar, Fri 3rd Apr, Sun 3rd May
            context "paid early" do
              let(:dates) { make_dates(%w[2020-03-03 2020-04-03 2020-05-01]) }

              it "is true" do
                expect(subject).to be true
              end
            end

            context "paid late" do
              let(:dates) { make_dates(%w[2020-03-03 2020-04-03 2020-05-04]) }

              it "is true" do
                expect(subject).to be true
              end
            end
          end
        end

        context "at beginning of sequence" do
          context "first payment would have been Saturday" do
            # would have been paid on Sat 6th Jun, Mon 6th Jul, Thu 6th Aug
            context "paid early" do
              let(:dates) { make_dates(%w[2020-06-05 2020-07-06 2020-08-06]) }

              it "is true" do
                expect(subject).to be true
              end
            end

            context "paid late" do
              let(:dates) { make_dates(%w[2020-06-08 2020-07-06 2020-08-06]) }

              it "is true" do
                expect(subject).to be true
              end
            end
          end
        end
      end

      context "bank holidays cause change in payment date" do
        context "bank holiday at beginning of date range" do
          context "payment date is before holiday" do
            let(:dates) { make_dates(%w[2019-07-08 2019-08-09 2019-09-09]) }

            it "is true" do
              expect(subject).to be true
            end
          end

          context "payment date is after holiday" do
            let(:dates) { make_dates(%w[2019-07-10 2019-08-09 2019-09-09]) }

            it "is true" do
              expect(subject).to be true
            end
          end
        end

        context "bank holiday in middle of date range" do
          context "payment date is before holiday" do
            let(:dates) { make_dates(%w[2019-06-09 2019-07-08 2019-08-09]) }

            it "returns true" do
              expect(subject).to be true
            end
          end

          context "payment date is after holiday" do
            let(:dates) { make_dates(%w[2019-06-09 2019-07-10 2019-08-09]) }

            it "returns true" do
              expect(subject).to be true
            end
          end

          context "bank_holiday_adjustment is more than one day" do
            let(:dates) { make_dates(%w[2019-06-09 2019-07-13 2019-08-09]) }

            it "returns false" do
              expect(subject).to be false
            end
          end
        end

        context "bank holiday at end of date range" do
          let(:dates) { make_dates(%w[2019-05-09 2019-06-09 2019-07-10]) }

          context "payment date is before holiday" do
            let(:dates) { make_dates(%w[2019-05-09 2019-06-09 2019-07-08]) }

            it "returns true" do
              expect(subject).to be true
            end
          end

          context "payment date is after holiday" do
            let(:dates) { make_dates(%w[2019-05-09 2019-06-09 2019-07-10]) }

            it "returns true" do
              expect(subject).to be true
            end
          end
        end
      end

      context "longer months after shorter months" do
        context "where February is included" do
          let(:dates) { make_dates(%w[2021-02-28 2021-03-29 2021-04-29]) }

          it { is_expected.to be true }
        end

        context "where February is in the middle" do
          let(:dates) { make_dates(%w[2021-01-31 2021-02-28 2021-03-31]) }

          it { is_expected.to be true }
        end

        context "not including February" do
          let(:dates) { make_dates(%w[2021-03-31 2021-04-30 2021-05-31]) }

          it { is_expected.to be true }
        end
      end

      def make_dates(array_of_string_dates)
        array_of_string_dates.map { |x| Date.parse(x) }
      end
    end
  end
end

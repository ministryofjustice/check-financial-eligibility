require "rails_helper"

module Calculators
  RSpec.describe MonthlyIncomeConverter do
    subject { described_class.new(frequency, payments) }

    let(:payments) { [203.44, 205.00, 205.00] }

    context "monthly" do
      let(:frequency) { :monthly }

      describe "error?" do
        it "returns false" do
          expect(subject.error?).to be false
        end
      end

      describe "monthly_amount" do
        it "returns the average monthly amount" do
          subject.error?
          expect(subject.monthly_amount).to eq 204.48
        end
      end
    end

    context "four_weekly" do
      let(:frequency) { :four_weekly }

      describe "error?" do
        it "returns false" do
          expect(subject.error?).to be false
        end
      end

      describe "monthly_amount" do
        it "returns the average for the calendar month" do
          subject.error?
          expect(subject.monthly_amount).to eq 221.52
        end
      end
    end

    context "two_weekly" do
      let(:frequency) { :two_weekly }

      describe "error?" do
        it "returns false" do
          expect(subject.error?).to be false
        end
      end

      describe "monthly_amount" do
        it "returns the average for the calendar month" do
          subject.error?
          expect(subject.monthly_amount).to eq 443.04
        end
      end
    end

    context "weekly" do
      let(:frequency) { :weekly }

      describe "error?" do
        it "returns false" do
          expect(subject.error?).to be false
        end
      end

      describe "monthly_amount" do
        it "returns the average for the calendar month" do
          subject.error?
          expect(subject.monthly_amount).to eq 886.08
        end
      end
    end

    context "unknown" do
      let(:frequency) { :unknown }
      let(:payments) { [203.44, 205.00, 205.00, 178.77, 290.12] }

      describe "error?" do
        it "returns false" do
          expect(subject.error?).to be false
        end
      end

      describe "monthly_amount" do
        it "returns the sum of payments divided by 3" do
          subject.error?
          expect(subject.monthly_amount).to eq 360.78
        end
      end
    end

    context "Unrecognized frequency" do
      let(:frequency) { :abcd }

      it "raises an error" do
        expect { subject.error? }.to raise_error("Unrecognized frequency")
      end
    end
  end
end

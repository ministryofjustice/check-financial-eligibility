require "rails_helper"

module Utilities
  RSpec.describe MonthlyAmountConverter do
    subject(:result) { described_class.call(frequency, value) }

    context "with frequency of three_monthly" do
      let(:frequency) { :three_monthly }
      let(:value) { 1000.00 }

      it "divides by 3 and rounds to 2 decimals" do
        expect(result).to be 333.33
      end
    end

    context "with frequency of monthly" do
      let(:frequency) { :monthly }
      let(:value) { 1000.001 }

      it "returns input value unaltered" do
        expect(result).to be 1000.001
      end
    end

    context "with frequency of four weekly" do
      let(:frequency) { :four_weekly }
      let(:value) { 1000.00 }

      it "divides by 4, multiples by 52, divides by 12 and rounds to 2 decimals" do
        expect(result).to be 1083.33
      end
    end

    context "with frequency of two weekly" do
      let(:frequency) { :two_weekly }
      let(:value) { 1000.00 }

      it "divides by 2, multiples by 52, divides by 12 and rounds to 2 decimals" do
        expect(result).to be 2166.67
      end
    end

    context "with frequency of weekly" do
      let(:frequency) { :weekly }
      let(:value) { 1000.00 }

      it "multiples by 52, divides by 12 and rounds to 2 decimals" do
        expect(result).to be 4333.33
      end
    end

    context "with invalid frequency" do
      let(:frequency) { :quarterly }
      let(:value) { 1000.00 }

      it "raises error" do
        expect { result }.to raise_error(ArgumentError, "unexpected frequency quarterly")
      end
    end

    context "with frequency as string" do
      subject(:result) { described_class.call("weekly", 1000.00) }

      it "calls matching calculation method" do
        expect(result).to be 4333.33
      end
    end
  end
end

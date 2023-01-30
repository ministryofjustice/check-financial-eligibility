require "rails_helper"

RSpec.describe ProceedingTypeThreshold do
  before { mock_lfa_responses }

  let(:date) { Date.new(2021, 4, 9) }
  let(:waivable_codes) { %i[DA001 DA002 DA003 DA004 DA005 DA006 DA007 DA020] }
  let(:unwaivable_codes) { %i[SE003 SE004 SE013 SE014] }
  let(:all_codes) { waivable_codes + unwaivable_codes }
  let(:threshold_types) { %i[capital_upper gross_income_upper disposable_income_upper] }

  subject(:threshold_value) do
    described_class.value_for(ccms_code, threshold, date)
  end

  describe ".value_for" do
    let(:ccms_code) { :DA005 }
    let(:threshold) { :capital_lower_certificated }

    context "not a waivable threshold" do
      it "forwards the request on to Threshold" do
        expect(Threshold).to receive(:value_for).with(threshold, at: date)
        threshold_value
      end

      it "gets standard value" do
        expect(threshold_value).to eq 3_000
      end
    end

    context "waivable threshold" do
      let(:threshold) { :capital_upper }

      context "waived ccms_code" do
        let(:ccms_code) { :DA020 }

        it "gets the infinite_gross_income_upper from Threshold" do
          expect(Threshold).to receive(:value_for).with(:infinite_gross_income_upper, at: date)
          threshold_value
        end

        it "returns the infinite upper value" do
          expect(threshold_value).to eq 999_999_999_999
        end
      end

      context "un-waived ccms code" do
        let(:ccms_code) { :SE013 }

        it "gets passes the call to Threshold" do
          expect(Threshold).to receive(:value_for).with(threshold, at: date)
          threshold_value
        end

        it "returns the threshold value" do
          expect(threshold_value).to eq Threshold.value_for(threshold, at: date)
        end
      end

      context "invalid threshold" do
        let(:threshold) { :minimum_wage }
        let(:ccms_code) { :DA003 }

        it "passes the call to Threshold" do
          expect(Threshold).to receive(:value_for).with(threshold, at: date)
          threshold_value
        end

        it "returns the value that Threshold returned: nil" do
          expect(threshold_value).to be_nil
        end
      end
    end
  end
end

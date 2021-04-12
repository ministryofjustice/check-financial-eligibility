require 'rails_helper'

RSpec.describe ProceedingTypeThreshold do
  let(:date) { Date.new(2021, 4, 9) }
  let(:waivable_codes) { %i[DA001 DA002 DA003 DA004 DA005 DA006 DA007 DA020] }
  let(:unwaivable_codes) { %i[SE003 SE004 SE013 SE014] }
  let(:all_codes) { waivable_codes + unwaivable_codes }

  subject { described_class.value_for(ccms_code, threshold, date) }

  describe '.value_for' do
    let(:ccms_code) { all_codes.sample }
    let(:threshold) { :capital_lower }

    context 'not a waivable threshold' do
      it 'forwards the request on to Threshold' do
        expect(Threshold).to receive(:value_for).with(threshold, at: date)
        subject
      end

      it 'gets standard value' do
        expect(subject).to eq 3_000
      end
    end

    context 'waivable threshold' do
      let(:threshold) { described_class::WAIVABLE_THRESHOLDS.sample }
      context 'waived ccms_code' do
        let(:ccms_code) { waivable_codes.sample }

        it 'gets the infinite_gross_income_upper from Threshold' do
          expect(Threshold).to receive(:value_for).with(:infinite_gross_income_upper, at: date)
          subject
        end

        it 'returns the infinite upper value' do
          expect(subject).to eq 999_999_999_999
        end
      end

      context 'un-waived ccms code' do
        let(:ccms_code) { unwaivable_codes.sample }
        it 'gets passes the call to Threshold' do
          expect(Threshold).to receive(:value_for).with(threshold, at: date)
          subject
        end

        it 'returns the threshold value' do
          expect(subject).to eq Threshold.value_for(threshold, at: date)
        end
      end

      context 'invalid ccms_code' do
        let(:ccms_code) { :XX999 }
        it 'raises' do
          expect { subject }.to raise_error KeyError, 'key not found: :XX999'
        end
      end

      context 'invalid threshold' do
        let(:threshold) { :minimum_wage }
        let(:ccms_code) { waivable_codes.sample }
        it 'passes the call to Threshold' do
          expect(Threshold).to receive(:value_for).with(threshold, at: date)
          subject
        end

        it 'returns the value that Threshold returned: nil' do
          expect(subject).to be_nil
        end
      end
    end
  end
end

require 'rails_helper'

module Creators
  RSpec.describe AssessmentEligibilityCreator do
    describe '.call' do
      let(:codes) { %w[DA001 SE013 SE004] }
      let(:assessment) { create :assessment, proceeding_type_codes: codes }

      subject { described_class.call(assessment) }

      it 'creates an assessment eligibiltiy record for each proceeding type code' do
        expect { subject }.to change { Eligibility::Assessment.count }.by(3)
        expect(assessment.eligibilities.map(&:proceeding_type_code)).to match_array codes
      end

      it 'sets the assessment result to pending on all of them' do
        subject
        expect(assessment.eligibilities.map(&:assessment_result).uniq).to eq ['pending']
      end

      it 'sets all thresholds to nil' do
        subject
        expect(assessment.eligibilities.map(&:upper_threshold).uniq).to eq [nil]
        expect(assessment.eligibilities.map(&:lower_threshold).uniq).to eq [nil]
      end
    end
  end
end

require 'rails_helper'

module WorkflowPredicate
  RSpec.describe BelowLowerCapitalThresholdPredicate do
    let(:predicate) { described_class.new(assessment) }
    let(:request_hash) { AssessmentRequestFixture.ruby_hash }
    let(:assessment) { create :assessment }
    let(:capital_summary) { assessment.capital_summary }
    let(:today) { Date.new(2019, 4, 2) }

    context 'unpopulated response' do
      it 'raises' do
        expect(capital_summary.capital_assessment_result).to eq 'pending'
        expect {
          predicate.call
        }.to raise_error RuntimeError, 'Disposable Capital Assessment has not been calculated'
      end
    end

    context 'below threshold' do
      let(:assessment) { create :assessment, :summarised_below_lower_threshold }
      it 'returns true' do
        expect(predicate.call).to be true
      end
    end

    context 'equal to threshold' do
      let(:assessment) { create :assessment, :summarised_at_lower_threshold }
      it 'returns false' do
        expect(predicate.call).to be false
      end
    end

    context 'above lower threshold' do
      let(:assessment) { create :assessment, :summarised_above_lower_threshold }
      it 'returns false' do
        expect(predicate.call).to be false
      end
    end
  end
end

require 'rails_helper'

module WorkflowPredicate
  RSpec.describe BelowLowerCapitalThresholdPredicate do
    let(:capital_summary) { create :capital_summary }
    let(:assessment) { capital_summary.assessment }
    let(:predicate) { described_class.new(assessment) }
    let(:request_hash) { AssessmentRequestFixture.ruby_hash }
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
      let(:capital_summary) { create :capital_summary, :summarised, :below_lower_threshold }
      it 'returns true' do
        expect(predicate.call).to be true
      end
    end

    context 'equal to threshold' do
      let(:threshold) { Faker::Number.between(from: 4_000, to: 5_000).round(2) }
      let(:capital_summary) { create :capital_summary, :summarised, lower_threshold: threshold, assessed_capital: threshold }
      it 'returns false' do
        expect(predicate.call).to be false
      end
    end

    context 'above lower threshold' do
      let(:capital_summary) { create :capital_summary, :summarised, :above_upper_threshold }
      it 'returns false' do
        expect(predicate.call).to be false
      end
    end
  end
end

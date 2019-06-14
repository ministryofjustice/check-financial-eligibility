require 'rails_helper'

module WorkflowPredicate
  RSpec.xdescribe BelowLowerCapitalThresholdPredicate do
    let(:predicate) { described_class.new(particulars) }
    let(:request_hash) { AssessmentRequestFixture.ruby_hash }
    let(:assessment) { create :assessment, request_payload: request_hash.to_json }
    let(:particulars) { AssessmentParticulars.new(assessment) }
    let(:today) { Date.new(2019, 4, 2) }

    xcontext 'unpopulated response' do
      it 'raises' do
        expect {
          predicate.call
        }.to raise_error RuntimeError, 'Disposable Capital Assessment has not been calculated'
      end
    end

    xcontext 'below threshold' do
      it 'returns true' do
        particulars.response.details.capital.total_capital_lower_threshold = 3_000.0
        particulars.response.details.capital.disposable_capital_assessment = 2_999.99
        expect(predicate.call).to be true
      end
    end

    context 'equal to threshold' do
      it 'returns false' do
        particulars.response.details.capital.total_capital_lower_threshold = 3_000.0
        particulars.response.details.capital.disposable_capital_assessment = 3_000.0
        expect(predicate.call).to be false
      end
    end

    context 'above threshold' do
      it 'returns false' do
        particulars.response.details.capital.total_capital_lower_threshold = 3_000.0
        particulars.response.details.capital.disposable_capital_assessment = 3_000.01
        expect(predicate.call).to be false
      end
    end
  end
end

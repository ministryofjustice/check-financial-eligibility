require 'rails_helper'

module WorkflowService
  RSpec.describe CapitalContributionService do
    context 'not contribution required state' do
      it 'raises' do
        capital_summary = create :capital_summary, :not_eligible
        expect {
          described_class.call(capital_summary)
        }.to raise_error 'Invalid capital assessment result for contribution calculation'
      end
    end

    context 'contribution_required state' do
      it 'returns the difference between the lower threshold and the assessed capital' do
        capital_summary = create :capital_summary, :contribution_required, lower_threshold: 3_000.0, assessed_capital: 4_322.56
        expect(described_class.call(capital_summary)).to eq 1_322.56
      end
    end
  end
end

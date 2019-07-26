require 'rails_helper'

module WorkflowService
  RSpec.describe NonLiquidCapitalAssessment do
    let(:assessment) { create :assessment }
    let(:service) { described_class.new(assessment.id) }

    context 'all positive supplied' do
      it 'adds them all together' do
        assessment.non_liquid_assets << non_liquid_capital
        expect(service.call).to eq 179_664.44
      end
    end

    context 'no values supplied' do
      it 'returns zero' do
        expect(service.call).to eq 0.0
      end
    end

    def non_liquid_capital
      [
        NonLiquidAsset.new(assessment_id: assessment.id, description: 'trust_fund', value: 100_000.0),
        NonLiquidAsset.new(assessment_id: assessment.id, description: 'Ming Vase', value: 30_000.0),
        NonLiquidAsset.new(assessment_id: assessment.id, description: 'Portfolie of stocks and shares', value: 49_664.44)
      ]
    end
  end
end

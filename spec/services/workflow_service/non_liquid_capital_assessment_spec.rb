require 'rails_helper'

module WorkflowService
  RSpec.describe NonLiquidCapitalAssessment do
    let(:service) { described_class.new(non_liquid_capital_request) }

    context 'all positive supplied' do
      let(:non_liquid_capital_request) { open_structify(non_liquid_capital) }
      it 'adds them all together' do
        expect(service.call).to eq 179_664.44
      end
    end

    context 'empty array supplied' do
      let(:non_liquid_capital_request) { open_structify([]) }
      it 'returns zero' do
        expect(service.call).to eq 0.0
      end
    end

    context 'nil supplied' do
      let(:non_liquid_capital_request) { open_structify(nil) }
      it 'returns zero' do
        expect(service.call).to eq 0.0
      end
    end

    def non_liquid_capital
      [
        {
          item_description: 'trust_fund',
          value: 100_000.0
        },
        {
          item_description: 'Ming Vase',
          value: 30_000
        },
        {
          item_description: 'Portfolie of stocks and shares',
          value: 49_664.44
        }
      ]
    end
  end
end

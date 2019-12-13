require 'rails_helper'

module Assessors
  RSpec.describe NonLiquidCapitalAssessor do
    let(:assessment) { create :assessment }
    let(:capital_summary) { assessment.capital_summary }
    let(:service) { described_class.new(assessment) }

    context 'all positive supplied' do
      before do
        create_list :non_liquid_capital_item, 3, capital_summary: capital_summary
      end
      it 'adds them all together' do
        expect(service.call).to eq capital_summary.non_liquid_capital_items.sum(&:value)
      end
    end

    context 'no values supplied' do
      it 'returns zero' do
        expect(service.call).to eq 0.0
      end
    end
  end
end

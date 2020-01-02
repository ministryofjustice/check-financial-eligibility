require 'rails_helper'

module Outgoings
  RSpec.describe HousingCost do
    describe 'allowable_amount' do
      context 'board_and_lodging' do
        it 'returns half the amount' do
          outgoing = create :housing_cost_outgoing, housing_cost_type: 'board_and_lodging', amount: 135.43
          expect(outgoing.allowable_amount).to eq 67.72
        end
      end

      context 'rent' do
        it 'returns the full amount' do
          outgoing = create :housing_cost_outgoing, housing_cost_type: 'rent', amount: 207.38
          expect(outgoing.allowable_amount).to eq 207.38
        end
      end

      context 'mortgage' do
        it 'returns the full amount' do
          outgoing = create :housing_cost_outgoing, housing_cost_type: 'mortgage', amount: 99.98
          expect(outgoing.allowable_amount).to eq 99.98
        end
      end
    end
  end
end

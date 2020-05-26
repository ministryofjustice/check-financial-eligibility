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

    describe '#client id' do
      it 'returns the value' do
        outgoing = create :housing_cost_outgoing, amount: 127.33, payment_date: Date.new(2019, 3, 2), client_id: '55b31f30-a198-45bd-9a43-a4e5b66fa42e'
        expect(outgoing.client_id).to eq '55b31f30-a198-45bd-9a43-a4e5b66fa42e'
      end
    end
  end
end

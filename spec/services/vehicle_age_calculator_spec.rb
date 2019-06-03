require 'rails_helper'

RSpec.describe VehicleAgeCalculator do
  let(:calculation_date) { Date.new(2019, 5, 25) }
  let(:vac) { VehicleAgeCalculator.new(purchase_date, calculation_date) }

  describe '#in_months' do
    context 'bought this month' do
      let(:purchase_date) { Date.parse('2019-05-03') }
      it 'is one month' do
        expect(vac.in_months).to eq 1
      end
    end

    context 'bought one month and one day ago' do
      let(:purchase_date) { Date.parse('2019-04-24') }
      it 'is two months' do
        expect(vac.in_months).to eq 2
      end
    end

    context 'bought one day less than one momth ago' do
      let(:purchase_date) { Date.parse('2019-04-26') }
      it 'is one months' do
        expect(vac.in_months).to eq 1
      end
    end
  end
end

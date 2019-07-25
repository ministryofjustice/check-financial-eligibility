require 'rails_helper'

RSpec.describe DateSlope do
  let(:days) { ['23-May-19', '21-May-19', '19-May-19'] }
  let(:dates) { days.map(&:to_time) }

  subject { described_class.call(dates) }

  describe '.call' do
    it 'returns the slope' do
      expect(subject).to eq(-2)
    end

    context 'with a positive slope' do
      let(:days) { ['20-May-19', '21-May-19', '22-May-19'] }
      it 'returns a positive slope' do
        expect(subject).to eq(1)
      end
    end

    context 'across month boundary' do
      let(:days) { ['1-May-2019', '30-May-2019', '29-Jun-2019', '28-Jul-2019'] }
      it 'adjusts for month end and returns a negative slope' do
        expect(subject).to eq(-1)
      end
    end
  end
end

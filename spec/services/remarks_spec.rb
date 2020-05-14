require 'rails_helper'

RSpec.describe Remarks do
  let(:remarks) { Remarks.new }

  describe '#remarks_hash' do
    context 'no remarks' do
      it 'returns and empty hash' do
        expect(remarks.remarks_hash).to eq({})
      end
    end
  end

  describe '#add' do
    context 'empty remarks hash' do
      context 'single id' do
        it 'returns a hash with just one id' do
          remarks.add(:other_income, :unknown_frequency, 'abc')
          expect(remarks.remarks_hash).to eq({ other_income: { unknown_frequency: ['abc'] } })
        end
      end

      context 'multiple ids' do
        it 'returns a hash with just multiple id' do
          remarks.add(:other_income, :unknown_frequency, 'abc', 'def')
          expect(remarks.remarks_hash).to eq({ other_income: { unknown_frequency: %w[abc def] } })
        end
      end
    end

    context 'with an existing remarks hash' do
      before { remarks.add(:other_income, :unknown_frequency, 'abc') }

      context 'adding another issue to an existing type' do
        it 'adds the new issue' do
          remarks.add(:other_income, :amount_variation, 'def', 'ghi')
          expected_hash = {
            other_income: {
              unknown_frequency: ['abc'],
              amount_variation: %w[def ghi]
            }
          }
          expect(remarks.remarks_hash).to eq expected_hash
        end
      end

      context 'adding a new type' do
        it 'adds the new type' do
          remarks.add(:state_benefits, :amount_variation, 'def', 'ghi')
          expected_hash = {
            other_income: {
              unknown_frequency: ['abc']
            },
            state_benefits: {
              amount_variation: %w[def ghi]
            }
          }
          expect(remarks.remarks_hash).to eq expected_hash
        end
      end
    end

    context 'invalid transaction type' do
      it 'raises' do
        expect {
          remarks.add('XXX', :unknown_frequency, 'aaa')
        }.to raise_error ArgumentError, 'Invalid type: XXX'
      end
    end

    context 'invalid issue' do
      it 'raises' do
        expect {
          remarks.add(:other_income, :wrong_dates, 'aaa')
        }.to raise_error ArgumentError, 'Invalid issue: wrong_dates'
      end
    end
  end

  describe '#as_json' do
    it 'returns the @remarks_hash' do
      remarks.add(:other_income, :unknown_frequency, 'abc')
      expect(remarks.as_json).to eq remarks.remarks_hash
    end
  end
end

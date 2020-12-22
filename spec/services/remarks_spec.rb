require 'rails_helper'

RSpec.describe Remarks do
  let(:assessment) { create :assessment }
  let(:remarks) { Remarks.new(assessment.id) }

  describe '#remarks_hash' do
    context 'no remarks' do
      it 'returns and empty hash' do
        expect(remarks.remarks_hash).to eq({})
      end
    end

    context 'with remarks' do
      it 'returns a hash of remarks' do
        remarks.add(:other_income_payment, :unknown_frequency, %w[abc def])
        expect(remarks.remarks_hash).to eq({ other_income_payment: { unknown_frequency: %w[abc def] } })
      end
    end
  end

  describe '#add' do
    context 'empty remarks hash' do
      context 'single id' do
        it 'returns a hash with just one id' do
          remarks.add(:other_income_payment, :unknown_frequency, ['abc'])
          expect(remarks.remarks_hash).to eq({ other_income_payment: { unknown_frequency: ['abc'] } })
        end
      end

      context 'multiple ids' do
        it 'returns a hash with just multiple id' do
          remarks.add(:other_income_payment, :unknown_frequency, %w[abc def])
          expect(remarks.remarks_hash).to eq({ other_income_payment: { unknown_frequency: %w[abc def] } })
        end
      end
    end

    context 'with an existing remarks hash' do
      before { remarks.add(:other_income_payment, :unknown_frequency, ['abc']) }

      context 'adding another issue to an existing type' do
        it 'adds the new issue' do
          remarks.add(:other_income_payment, :amount_variation, %w[def ghi])
          expected_hash = {
            other_income_payment: {
              unknown_frequency: ['abc'],
              amount_variation: %w[def ghi]
            }
          }
          expect(remarks.remarks_hash).to eq expected_hash
        end
      end

      context 'adding a new type' do
        it 'adds the new type' do
          remarks.add(:state_benefit_payment, :amount_variation, %w[def ghi])
          expected_hash = {
            other_income_payment: {
              unknown_frequency: ['abc']
            },
            state_benefit_payment: {
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
          remarks.add(:other_income_payment, :wrong_dates, 'aaa')
        }.to raise_error ArgumentError, 'Invalid issue: wrong_dates'
      end
    end
  end

  describe '#as_json' do
    it 'returns the @remarks_hash' do
      remarks.add(:other_income_payment, :unknown_frequency, ['abc'])
      expect(remarks.as_json).to eq remarks.remarks_hash
    end

    context 'with explicit remarks' do
      before do
        create :explicit_remark, assessment: assessment, remark: 'Jacob Creuzfeldt disease fund'
        create :explicit_remark, assessment: assessment, remark: 'Grenfell tower fund'
      end

      it 'adds in the explicit remarks' do
        remarks.add(:other_income_payment, :unknown_frequency, %w[abc def])
        expect(remarks.as_json).to have_key(:income_disregards)
        expect(remarks.as_json[:income_disregards]).to eq ['Grenfell tower fund', 'Jacob Creuzfeldt disease fund']
      end
    end
  end
end

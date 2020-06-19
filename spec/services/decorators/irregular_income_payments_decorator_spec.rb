require 'rails_helper'

module Decorators
  RSpec.describe IrregularIncomePaymentsDecorator do
    describe '#as_json' do
      subject { described_class.new(record).as_json }

      let(:record) { create :irregular_income_payment, amount: 12_000 }

      it 'returns expected hash' do
        expected_hash = {
          payments: [
            {
              income_type: 'student_loan',
              frequency: record.frequency,
              amount: 12_000.0
            }
          ]
        }
        expect(subject).to eq expected_hash
      end

      context 'no irregular income payments' do
        let(:record) { nil }
        it 'returns expected hash' do
          expected_hash = {
            payments: []
          }
          expect(subject).to eq expected_hash
        end
      end
    end
  end
end

require 'rails_helper'

module Decorators
  RSpec.describe MonthlyIncomeEquivalentDecorator do
    describe '#as_json' do
      subject { described_class.new(record).as_json }

      let(:record) { income_sources }

      it 'returns expected hash' do
        expected_hash = {
          friends_or_family: 0.0,
          maintenance_in: 0.0,
          property_or_lodger: 0.0,
          pension: 0.0,
          student_loan: 250
        }
        expect(subject).to eq expected_hash
      end

      context 'record contains irregular income payments' do
        let!(:record) { income_sources }
        before { record.irregular_income_payments = 12_000 }

        it 'returns expected hash' do
          expected_hash = {
            friends_or_family: 0.0,
            maintenance_in: 0.0,
            property_or_lodger: 0.0,
            pension: 0.0
          }
          expect(subject).to eq expected_hash
        end
      end

      def income_sources
        OpenStruct.new(
          friends_or_family: 0.0,
          maintenance_in: 0.0,
          property_or_lodger: 0.0,
          pension: 0.0,
          student_loan: 250.0
        )
      end
    end
  end
end

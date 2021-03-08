require 'rails_helper'

module Decorators
  RSpec.describe OtherIncomeSourceDecorator do
    describe '#as_json' do
      subject { described_class.new(record).as_json }

      let(:record) { create :gross_income_summary, :with_everything, :with_all_transaction_types }
      it 'returns expected hash containing monthly transactions for all income types except benefits' do
        expected_hash = {
          monthly_equivalents: {
            bank_transactions: {
              friends_or_family: 7.47,
              maintenance_in: 115.04,
              property_or_lodger: 483.47,
              pension: 27.4
            },
            cash_transactions: {
              friends_or_family: 255.34,
              maintenance_in: 1038.07,
              property_or_lodger: 0.0,
              pension: 0.0
            },
            all_sources: {
              friends_or_family: 262.81,
              maintenance_in: 1153.11,
              property_or_lodger: 483.47,
              pension: 27.4
            }
          }
        }
        expect(subject).to eq expected_hash
      end
    end
  end
end

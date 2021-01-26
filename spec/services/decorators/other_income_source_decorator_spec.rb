require 'rails_helper'

module Decorators
  RSpec.describe OtherIncomeSourceDecorator do
    describe '#as_json' do
      context 'version 2' do
        subject { described_class.new(record).as_json }

        let(:record) { create :other_income_source, :with_monthly_payments, name: 'friends_or_family', monthly_income: 250.00 }
        it 'returns expected hash' do
          expected_hash = {
            name: 'friends_or_family',
            monthly_income: 250.0,
            payments: [
              {
                payment_date: Date.current,
                amount: 75.0
              },
              {
                payment_date: 1.month.ago.to_date,
                amount: 75.0
              },
              {
                payment_date: 2.months.ago.to_date,
                amount: 75.0
              }
            ]
          }
          expect(subject).to eq expected_hash
        end
      end

      context 'version 3' do
        subject { described_class.new(record).as_json }

        let(:record) { create :gross_income_summary, :with_everything, :with_all_transaction_types, :with_latest_version }
        it 'returns expected hash' do
          expected_hash = {
            monthly_equivalents: {
              bank_transactions: {
                benefits: 34.16,
                friends_or_family: 7.47,
                maintenance_in: 115.04,
                property_or_lodger: 483.47,
                pension: 27.4
              },
              cash_transactions: {
                benefits: 1038.07,
                friends_or_family: 255.34,
                maintenance_in: 1038.07,
                property_or_lodger: 0.0,
                pension: 0.0
              },
              all_sources: {
                benefits: 1072.23,
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
end

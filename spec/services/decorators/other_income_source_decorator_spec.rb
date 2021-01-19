require 'rails_helper'

module Decorators
  RSpec.describe OtherIncomeSourceDecorator do
    describe '#as_json' do
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
  end
end

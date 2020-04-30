require 'rails_helper'

module Decorators
  RSpec.describe StateBenefitDecorator do
    describe '#as_json' do
      let(:record) { create :state_benefit, :with_monthly_payments, name: 'Childcare allowance' }
      let(:excluded) { record.state_benefit_type.exclude_from_gross_income }

      subject { described_class.new(record).as_json }

      it 'returns the expected hash' do
        expected_hash = {
          name: 'Childcare allowance',
          monthly_value: 88.3,
          excluded_from_income_assessment: excluded,
          state_benefit_payments:
            [
              { payment_date: Date.today, amount: 88.30 },
              { payment_date: 1.month.ago.to_date, amount: 88.3 },
              { payment_date: 2.months.ago.to_date, amount: 88.3 }
            ]
        }
        expect(subject).to eq expected_hash
      end
    end
  end
end

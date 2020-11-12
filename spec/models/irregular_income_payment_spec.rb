require 'rails_helper'

RSpec.describe IrregularIncomePayment, type: :model do
  let!(:gross_income_summary) { create :gross_income_summary }
  let!(:payment) { create :irregular_income_payment, gross_income_summary: gross_income_summary }

  context 'validations' do
    context 'invalid income type' do
      let(:payment) { build :irregular_income_payment, gross_income_summary: gross_income_summary, income_type: 'xxx' }

      it 'is not valid' do
        expect(payment).not_to be_valid
        expect(payment.errors[:income_type]).to eq(['is not included in the list'])
      end
    end

    context 'frequency' do
      let(:payment) { build :irregular_income_payment, gross_income_summary: gross_income_summary, frequency: 'xxx' }

      it 'is not valid' do
        expect(payment).not_to be_valid
        expect(payment.errors[:frequency]).to eq(['is not included in the list'])
      end
    end

    context 'duplicate income types' do
      let(:payment) { create :irregular_income_payment, gross_income_summary: gross_income_summary }

      context 'one student loan per assessment' do
        let(:gross_income_summary2) { create :gross_income_summary }
        let(:payment2) { build :irregular_income_payment, gross_income_summary: gross_income_summary2 }

        it 'is valid' do
          expect { payment2.save! }.not_to raise_error
        end
      end

      context 'multiple student loans per assessment' do
        let(:payment2) { build :irregular_income_payment, gross_income_summary: gross_income_summary }

        it 'is valid' do
          expect { payment2.save! }.to raise_error(ActiveRecord::RecordNotUnique)
        end
      end
    end

    context 'amount is less than zero' do
      let!(:payment) do
        build :irregular_income_payment, amount: -1, gross_income_summary: gross_income_summary
      end

      it 'raises error' do
        expect { payment.save! }.to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Amount must be greater than or equal to 0')
      end
    end
  end
end

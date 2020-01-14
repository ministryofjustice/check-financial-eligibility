require 'rails_helper'

RSpec.describe OtherIncomeSource, type: :model do
  describe '#calculate_monthly_income' do
    let(:source) { create :other_income_source }
    let!(:payment1) { create :other_income_payment, other_income_source: source, payment_date: 3.months.ago.to_date, amount: 301.0 }
    let!(:payment2) { create :other_income_payment, other_income_source: source, payment_date: 2.months.ago.to_date, amount: 302.0 }
    let!(:payment3) { create :other_income_payment, other_income_source: source, payment_date: 1.months.ago.to_date, amount: 301.50 }
    let(:analyser) { double Utilities::PaymentPeriodAnalyser }

    before do
      expect(Utilities::PaymentPeriodDataExtractor).to receive(:call)
        .with(collection: source.other_income_payments,
              date_method: :payment_date,
              amount_method: :amount)
      expect(Utilities::PaymentPeriodAnalyser).to receive(:new).and_return(analyser)
    end

    subject { source.calculate_monthly_income! }

    context 'valid payment frequency' do
      before { expect(analyser).to receive(:period_pattern).and_return(:monthly) }

      it 'updates the monthly_income field with the result' do
        subject
        expect(source.reload.monthly_income).to eq 301.5
      end

      it 'returns the result' do
        expect(subject).to eq 301.5
      end

      it 'does not write an assessment_error_record' do
        expect { subject }.not_to change { AssessmentError.count }
      end
    end

    context 'unknown payment frequency' do
      before { expect(analyser).to receive(:period_pattern).and_return(:unknown) }

      it 'raises an exception' do
        expect {
          subject
        }.to raise_error RuntimeError, /Unable to calculate payment frequency for OtherIncomeSource with payment dates \[.*\]/
      end
    end
  end
end

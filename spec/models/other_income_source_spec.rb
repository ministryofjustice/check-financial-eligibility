require 'rails_helper'

RSpec.describe OtherIncomeSource, type: :model do
  describe '#calculate_monthly_income' do
    let(:source) { create :other_income_source }
    let!(:payment1) { create :other_income_payment, other_income_source: source, payment_date: 3.months.ago.to_date, amount: 301.0 }
    let!(:payment2) { create :other_income_payment, other_income_source: source, payment_date: 2.months.ago.to_date, amount: 302.0 }
    let!(:payment3) { create :other_income_payment, other_income_source: source, payment_date: 1.months.ago.to_date, amount: 301.50 }
    let(:analyser) { double PaymentPeriodAnalyser }

    before do
      expect(PaymentPeriodDataExtractor).to receive(:call)
        .with(collection: source.other_income_payments,
              date_method: :payment_date,
              amount_method: :amount)
      expect(PaymentPeriodAnalyser).to receive(:new).and_return(analyser)
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

      it 'does not updates the monthly_income field' do
        subject
        expect(source.reload.monthly_income).to eq nil
      end

      it 'returns nil' do
        expect(subject).to be_nil
      end

      it 'writes an assessment_error_record' do
        expect { subject }.to change { AssessmentError.count }.by(1)
        assessment_error = source.assessment.assessment_errors.first
        expect(assessment_error.record_id).to eq source.id
        expect(assessment_error.record_type).to eq source.class.to_s
        expect(assessment_error.error_message).to eq 'unknown_payment_frequency'
      end
    end
  end
end

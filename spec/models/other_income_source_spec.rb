require "rails_helper"

RSpec.describe OtherIncomeSource, type: :model do
  describe "#calculate_monthly_income" do
    let(:source) { create :other_income_source }
    let!(:payment1) { create :other_income_payment, other_income_source: source, payment_date: 3.months.ago.to_date, amount: 301.0 }
    let!(:payment2) { create :other_income_payment, other_income_source: source, payment_date: 2.months.ago.to_date, amount: 302.0 }
    let!(:payment3) { create :other_income_payment, other_income_source: source, payment_date: 1.month.ago.to_date, amount: 301.50 }
    let(:analyser) { double Utilities::PaymentPeriodAnalyser }

    before do
      expect(Utilities::PaymentPeriodDataExtractor).to receive(:call)
        .with(collection: source.other_income_payments,
              date_method: :payment_date,
              amount_method: :amount)
        .and_return([%i[dummy_date1 dummy_amount1], %i[dummy_date2 dummy_amount2]])
      expect(Utilities::PaymentPeriodAnalyser).to receive(:new).and_return(analyser)
    end

    subject { source.calculate_monthly_income! }

    context "valid payment frequency" do
      before { expect(analyser).to receive(:period_pattern).and_return(:monthly) }

      it "updates the monthly_income field with the result" do
        subject
        expect(source.reload.monthly_income).to eq 301.5
      end

      it "returns the result" do
        expect(subject).to eq 301.5
      end

      it "does not write an assessment_error_record" do
        expect { subject }.not_to change(AssessmentError, :count)
      end
    end

    context "unknown payment frequency" do
      before { expect(analyser).to receive(:period_pattern).and_return(:unknown) }

      let!(:payment1) { create :other_income_payment, other_income_source: source, payment_date: 1.day.ago.to_date, amount: 301.0 }
      let!(:payment2) { create :other_income_payment, other_income_source: source, payment_date: 5.days.ago.to_date, amount: 123.45 }
      let!(:payment3) { create :other_income_payment, other_income_source: source, payment_date: 45.days.ago.to_date, amount: 87.10 }
      let!(:payment4) { create :other_income_payment, other_income_source: source, payment_date: 45.days.ago.to_date, amount: 30.0 }

      it "returns the average monthly payment over three months" do
        expect(subject).to eq 180.52
      end
    end
  end
end

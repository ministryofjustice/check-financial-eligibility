require 'rails_helper'

module Collators
  RSpec.describe LegalAidCollator do
    let(:assessment) { create :assessment, :with_disposable_income_summary }
    let(:disposable_income_summary) { assessment.disposable_income_summary }

    describe '.call' do
      subject { described_class.call(assessment) }

      context 'when there are no legal_aid outgoings' do
        it 'leaves the monthly maintenance field on the disposable income summary as zero' do
          subject
          expect(disposable_income_summary.reload.legal_aid).to be_zero
        end
      end

      context 'when there are legal_aid outgoings' do
        before do
          # payments every 28 days which equals 112.08 per calendar month
          create :legal_aid_outgoing, disposable_income_summary: disposable_income_summary, payment_date: 2.days.ago, amount: 103.46
          create :legal_aid_outgoing, disposable_income_summary: disposable_income_summary, payment_date: 30.days.ago, amount: 103.46
          create :legal_aid_outgoing, disposable_income_summary: disposable_income_summary, payment_date: 58.days.ago, amount: 103.46

          # childcare payments should be ignored
          create :childcare_outgoing, disposable_income_summary: disposable_income_summary, payment_date: 10.days.ago, amount: 99.00
          create :childcare_outgoing, disposable_income_summary: disposable_income_summary, payment_date: 28.days.ago, amount: 99.00
          create :childcare_outgoing, disposable_income_summary: disposable_income_summary, payment_date: 66.days.ago, amount: 99.00
        end

        it 'calculates the monthly equivalent and updates the disposable income summary' do
          subject
          expect(disposable_income_summary.reload.legal_aid).to eq 112.08
        end
      end
    end
  end
end

require "rails_helper"

module Collators
  RSpec.describe ChildcareCollator do
    describe ".call" do
      let(:assessment) { create :assessment, :with_disposable_income_summary, :with_gross_income_summary }
      let(:disposable_income_summary) { assessment.disposable_income_summary }
      let(:gross_income_summary) { assessment.gross_income_summary }
      let(:target_time) { Date.current }

      subject(:collator) do
        described_class.call(gross_income_summary:, disposable_income_summary:, eligible_for_childcare:)
      end

      before do
        travel_to target_time
        create :bank_holiday
        create :childcare_outgoing, disposable_income_summary:, payment_date: Date.yesterday, amount: 155.63
        create :childcare_outgoing, disposable_income_summary:, payment_date: 1.month.ago, amount: 155.63
        create :childcare_outgoing, disposable_income_summary:, payment_date: 2.months.ago, amount: 155.63
      end

      context "Not eligible for childcare" do
        let(:eligible_for_childcare) { false }

        it "does not update the childcare value on the disposable income summary" do
          collator
          expect(disposable_income_summary.child_care_bank).to eq 0.0
        end
      end

      context "Eligible for childcare" do
        let(:eligible_for_childcare) { true }

        it "updates the childcare value on the disposable income summary" do
          collator
          expect(disposable_income_summary.child_care_bank).to eq 155.63
        end
      end
    end
  end
end

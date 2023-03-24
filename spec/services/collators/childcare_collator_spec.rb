require "rails_helper"

module Collators
  RSpec.describe ChildcareCollator do
    describe ".call" do
      let(:assessment) { create :assessment, :with_disposable_income_summary, :with_gross_income_summary }
      let(:disposable_income_summary) { assessment.disposable_income_summary }
      let(:gross_income_summary) { assessment.gross_income_summary }
      let(:target_time) { Date.current }
      let(:childcare_outgoings) do
        [
          build(:childcare_outgoing, payment_date: Date.yesterday, amount: 155.63),
          build(:childcare_outgoing, payment_date: 1.month.ago, amount: 155.63),
          build(:childcare_outgoing, payment_date: 2.months.ago, amount: 155.63),
        ]
      end

      subject(:collator) do
        described_class.call(gross_income_summary:, childcare_outgoings:, eligible_for_childcare:,
                             assessment_errors: assessment.assessment_errors)
      end

      before do
        travel_to target_time
        create :bank_holiday
      end

      context "Not eligible for childcare" do
        let(:eligible_for_childcare) { false }

        it "does not update the childcare value on the disposable income summary" do
          expect(collator.bank).to eq 0.0
        end
      end

      context "Eligible for childcare" do
        let(:eligible_for_childcare) { true }

        it "updates the childcare value on the disposable income summary" do
          expect(collator.bank).to eq 155.63
        end
      end
    end
  end
end

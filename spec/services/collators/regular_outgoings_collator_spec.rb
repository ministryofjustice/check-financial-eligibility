require "rails_helper"

# regular_outgoings_transactions needs to:
# 1. work out monthly equivalent values for each category of debit operation
# 1. increment all _all_sources for each category of debit operation
# 2. increment total_outgoings_and_allowances, except for rent_or_mortgate**
# 3. decrement total_disposable_income, except for rent_or_mortgate**
#
# ** in full NonPassportedWorkflow :rent_or_mortgate will already been added
# to totals by the HousingCostCollator/HousingCostCalculator and DisposableIncomeCollator :(
#

RSpec.describe Collators::RegularOutgoingsCollator do
  let(:assessment) { create(:assessment, :with_applicant, :with_gross_income_summary, :with_disposable_income_summary) }
  let(:gross_income_summary) { assessment.gross_income_summary }
  let(:disposable_income_summary) { assessment.disposable_income_summary }
  let(:eligible_for_childcare) { true }

  describe ".call" do
    subject(:collator) do
      described_class.call(gross_income_summary:, disposable_income_summary:, eligible_for_childcare:)
    end

    context "without monthly regular transactions" do
      it "does increments #<cagtegory>_all_sources data" do
        collator
        disposable_income_summary.reload
        expect(disposable_income_summary).to have_attributes(
          child_care_all_sources: 0.0,
          rent_or_mortgage_all_sources: 0.0,
          maintenance_out_all_sources: 0.0,
          legal_aid_all_sources: 0.0,
        )
      end

      it "does not increment #total_outgoings_and_allowances" do
        collator
        disposable_income_summary.reload
        expect(disposable_income_summary.total_outgoings_and_allowances).to be_zero
      end

      it "does not decrement #total_disposable_income" do
        collator
        disposable_income_summary.reload
        expect(disposable_income_summary.total_disposable_income).to be_zero
      end
    end

    context "with monthly regular transactions" do
      before do
        create(:regular_transaction, gross_income_summary:, operation: "debit", category: "maintenance_out", frequency: "monthly", amount: 111.11)
        create(:regular_transaction, gross_income_summary:, operation: "debit", category: "legal_aid", frequency: "monthly", amount: 222.22)
        create(:regular_transaction, gross_income_summary:, operation: "credit", category: "maintenance_in", frequency: "monthly", amount: 12_000)
      end

      it "increments #<cagtegory>_all_sources data" do
        collator
        disposable_income_summary.reload
        expect(disposable_income_summary).to have_attributes(
          child_care_all_sources: 0.0,
          maintenance_out_all_sources: 111.11,
          rent_or_mortgage_all_sources: 0.0,
          legal_aid_all_sources: 222.22,
        )
      end

      it "increments #total_outgoings_and_allowances" do
        collator
        disposable_income_summary.reload
        expect(disposable_income_summary.total_outgoings_and_allowances).to eq 333.33
      end

      it "decrements #total_disposable_income" do
        collator
        disposable_income_summary.reload
        expect(disposable_income_summary.total_disposable_income).to eq(-333.33)
      end
    end

    context "with four_weekly regular transactions" do
      before do
        create(:regular_transaction, gross_income_summary:, operation: "debit", category: "maintenance_out", frequency: "four_weekly", amount: 111.11)
        create(:regular_transaction, gross_income_summary:, operation: "debit", category: "legal_aid", frequency: "four_weekly", amount: 222.22)
        create(:regular_transaction, gross_income_summary:, operation: "credit", category: "maintenance_in", frequency: "four_weekly", amount: 12_000)
      end

      it "increments #<cagtegory>_all_sources data" do
        collator
        disposable_income_summary.reload
        expect(disposable_income_summary).to have_attributes(
          child_care_all_sources: 0.0,
          maintenance_out_all_sources: 120.37,
          rent_or_mortgage_all_sources: 0.0,
          legal_aid_all_sources: 240.74,
        )
      end

      it "increments #total_outgoings_and_allowances" do
        collator
        disposable_income_summary.reload
        expect(disposable_income_summary.total_outgoings_and_allowances).to eq 361.11
      end

      it "decrements #total_disposable_income" do
        collator
        disposable_income_summary.reload
        expect(disposable_income_summary.total_disposable_income).to eq(-361.11)
      end
    end

    context "with two_weekly regular transactions" do
      before do
        create(:regular_transaction, gross_income_summary:, operation: "debit", category: "maintenance_out", frequency: "two_weekly", amount: 111.11)
        create(:regular_transaction, gross_income_summary:, operation: "debit", category: "legal_aid", frequency: "two_weekly", amount: 222.22)
        create(:regular_transaction, gross_income_summary:, operation: "credit", category: "maintenance_in", frequency: "two_weekly", amount: 12_000)
      end

      it "increments #<cagtegory>_all_sources data" do
        collator
        disposable_income_summary.reload
        expect(disposable_income_summary).to have_attributes(
          child_care_all_sources: 0.0,
          maintenance_out_all_sources: 240.74,
          rent_or_mortgage_all_sources: 0.0,
          legal_aid_all_sources: 481.48,
        )
      end

      it "increments #total_outgoings_and_allowances" do
        collator
        disposable_income_summary.reload
        expect(disposable_income_summary.total_outgoings_and_allowances).to eq 722.22
      end

      it "decrements for #total_disposable_income" do
        collator
        disposable_income_summary.reload
        expect(disposable_income_summary.total_disposable_income).to eq(-722.22)
      end
    end

    context "with weekly regular transaction" do
      before do
        create(:regular_transaction, gross_income_summary:, operation: "debit", category: "maintenance_out", frequency: "weekly", amount: 111.11)
        create(:regular_transaction, gross_income_summary:, operation: "debit", category: "legal_aid", frequency: "weekly", amount: 222.22)
        create(:regular_transaction, gross_income_summary:, operation: "credit", category: "maintenance_in", frequency: "weekly", amount: 12_000)
      end

      it "increments #<cagtegory>_all_sources data" do
        collator
        disposable_income_summary.reload
        expect(disposable_income_summary).to have_attributes(
          child_care_all_sources: 0.0,
          maintenance_out_all_sources: 481.48,
          rent_or_mortgage_all_sources: 0.0,
          legal_aid_all_sources: 962.95,
        )
      end

      it "increments #total_outgoings_and_allowances" do
        collator
        disposable_income_summary.reload
        expect(disposable_income_summary.total_outgoings_and_allowances).to eq 1444.43
      end

      it "decrements for #total_disposable_income" do
        collator
        disposable_income_summary.reload
        expect(disposable_income_summary.total_disposable_income).to eq(-1444.43)
      end
    end

    # ** see above for reason
    context "with monthly regular transactions of :rent_or_mortgage" do
      before do
        create(:regular_transaction, gross_income_summary:, operation: "debit", category: "rent_or_mortgage", frequency: "monthly", amount: 222.22)
      end

      it "increments #rent_or_mortgage_all_sources data" do
        collator
        disposable_income_summary.reload
        expect(disposable_income_summary).to have_attributes(
          child_care_all_sources: 0.0,
          maintenance_out_all_sources: 0.0,
          rent_or_mortgage_all_sources: 222.22,
          legal_aid_all_sources: 0.00,
        )
      end

      it "does not increment #total_outgoings_and_allowances" do
        collator
        disposable_income_summary.reload
        expect(disposable_income_summary.total_outgoings_and_allowances).to be_zero
      end

      it "does not decrement #total_disposable_income" do
        collator
        disposable_income_summary.reload
        expect(disposable_income_summary.total_disposable_income).to be_zero
      end
    end

    context "with monthly regular transaction of :child_care" do
      before do
        create(:regular_transaction,
               gross_income_summary:,
               operation: "debit",
               category: "child_care",
               frequency: "monthly", amount: 111.11)
      end

      context "when eligible for childcare" do
        it "increments #child_care_all_sources data" do
          expect { collator }.to change { disposable_income_summary.reload.child_care_all_sources }.from(0).to(111.11)
        end

        it "increments #total_outgoings_and_allowances" do
          expect { collator }.to change { disposable_income_summary.reload.total_outgoings_and_allowances }.from(0).to(111.11)
        end

        it "decrements #total_disposable_income" do
          expect { collator }.to change { disposable_income_summary.reload.total_disposable_income }.from(0).to(-111.11)
        end
      end

      context "when not eligible for childcare" do
        let(:eligible_for_childcare) { false }

        it "does not increment #child_care_all_sources data" do
          expect { collator }.not_to change { disposable_income_summary.reload.child_care_all_sources }.from(0)
        end

        it "does not increment #total_outgoings_and_allowances" do
          expect { collator }.not_to change { disposable_income_summary.reload.total_outgoings_and_allowances }.from(0)
        end

        it "does not decrement #total_disposable_income" do
          expect { collator }.not_to change { disposable_income_summary.reload.total_disposable_income }.from(0)
        end
      end
    end

    context "with multiple regular transactions of same operation and category" do
      before do
        create(:regular_transaction, gross_income_summary:, operation: "debit", category: "maintenance_out", frequency: "monthly", amount: 111.11)
        create(:regular_transaction, gross_income_summary:, operation: "debit", category: "maintenance_out", frequency: "monthly", amount: 222.22)
      end

      it "increments their values into single #<cagtegory>_all_sources data" do
        collator
        disposable_income_summary.reload
        expect(disposable_income_summary).to have_attributes(
          child_care_all_sources: 0.0,
          maintenance_out_all_sources: 333.33,
          rent_or_mortgage_all_sources: 0.0,
          legal_aid_all_sources: 0.0,
        )
      end

      it "increments #total_outgoings_and_allowances" do
        collator
        disposable_income_summary.reload
        expect(disposable_income_summary.total_outgoings_and_allowances).to eq 333.33
      end

      it "decrements for #total_disposable_income" do
        collator
        disposable_income_summary.reload
        expect(disposable_income_summary.total_disposable_income).to eq(-333.33)
      end
    end

    context "with existing data" do
      before do
        assessment.disposable_income_summary.update!(
          maintenance_out_bank: 0.0,
          maintenance_out_cash: 333.33,
          maintenance_out_all_sources: 333.33,
          total_outgoings_and_allowances: 333.33,
          total_disposable_income: 9_666.66,
        )
      end

      it "has expected values prior to regular outgoings collation" do
        expect(disposable_income_summary).to have_attributes(
          maintenance_out_bank: 0.0,
          maintenance_out_cash: 333.33,
          maintenance_out_all_sources: 333.33,
          rent_or_mortgage_bank: 0.0,
          rent_or_mortgage_cash: 0.0,
          rent_or_mortgage_all_sources: 0.0,
          total_outgoings_and_allowances: 333.33,
          total_disposable_income: 9_666.66,
        )
      end

      context "with monthly regular transactions" do
        before do
          create(:regular_transaction, gross_income_summary:, operation: "debit", category: "maintenance_out", frequency: "monthly", amount: 1000.00)
          create(:regular_transaction, gross_income_summary:, operation: "debit", category: "legal_aid", frequency: "monthly", amount: 2000.00)
        end

        it "increments #<cagtegory>_all_sources data to existing values" do
          collator
          disposable_income_summary.reload
          expect(disposable_income_summary).to have_attributes(
            child_care_all_sources: 0.0,
            maintenance_out_all_sources: 1_333.33,
            rent_or_mortgage_all_sources: 0.0,
            legal_aid_all_sources: 2_000.00,
          )
        end

        it "increments #total_outgoings_and_allowances against existing value" do
          collator
          disposable_income_summary.reload
          expect(disposable_income_summary.total_outgoings_and_allowances).to eq 3_333.33
        end

        it "decrements #total_disposable_income against existing value" do
          collator
          disposable_income_summary.reload
          expect(disposable_income_summary.total_disposable_income).to eq 6_666.66
        end
      end
    end
  end
end

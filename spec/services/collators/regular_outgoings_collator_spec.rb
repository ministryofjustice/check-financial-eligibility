require "rails_helper"

# regular_outgoings_transactions needs to
# 1. work out monthly equivalent values for each category of debit operation
# 1. increment/sum to all _all_sources for each category of debit operation
# 2. increment/sum total_outgoings_and_allowances
# 3. increment/sum total_disposable_income
#
# However, it cannot amend housing currently?!
# child_care: Outgoings::Childcare,
# rent_or_mortgage: Outgoings::HousingCost,
# maintenance_out: Outgoings::Maintenance,
# legal_aid: Outgoings::LegalAid,

RSpec.describe Collators::RegularOutgoingsCollator do
  let(:assessment) { create(:assessment, :with_applicant, :with_gross_income_summary, :with_disposable_income_summary) }
  let(:gross_income_summary) { assessment.gross_income_summary }
  let(:disposable_income_summary) { assessment.disposable_income_summary }

  describe ".call" do
    subject(:collator) { described_class.call(assessment) }

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
        create(:regular_transaction, gross_income_summary:, operation: "debit", category: "rent_or_mortgage", frequency: "monthly", amount: 222.22)
        create(:regular_transaction, gross_income_summary:, operation: "credit", category: "maintenance_in", frequency: "monthly", amount: 12_000)
      end

      it "increments #<cagtegory>_all_sources data" do
        collator
        disposable_income_summary.reload
        expect(disposable_income_summary).to have_attributes(
          child_care_all_sources: 0.0,
          maintenance_out_all_sources: 111.11,
          rent_or_mortgage_all_sources: 222.22,
          legal_aid_all_sources: 0.0,
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
        create(:regular_transaction, gross_income_summary:, operation: "debit", category: "rent_or_mortgage", frequency: "four_weekly", amount: 222.22)
        create(:regular_transaction, gross_income_summary:, operation: "credit", category: "maintenance_in", frequency: "four_weekly", amount: 12_000)
      end

      it "increments #<cagtegory>_all_sources data" do
        collator
        disposable_income_summary.reload
        expect(disposable_income_summary).to have_attributes(
          child_care_all_sources: 0.0,
          maintenance_out_all_sources: 120.37,
          rent_or_mortgage_all_sources: 240.74,
          legal_aid_all_sources: 0.0,
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
        create(:regular_transaction, gross_income_summary:, operation: "debit", category: "rent_or_mortgage", frequency: "two_weekly", amount: 222.22)
        create(:regular_transaction, gross_income_summary:, operation: "credit", category: "maintenance_in", frequency: "two_weekly", amount: 12_000)
      end

      it "increments #<cagtegory>_all_sources data" do
        collator
        disposable_income_summary.reload
        expect(disposable_income_summary).to have_attributes(
          child_care_all_sources: 0.0,
          maintenance_out_all_sources: 240.74,
          rent_or_mortgage_all_sources: 481.48,
          legal_aid_all_sources: 0.0,
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
        create(:regular_transaction, gross_income_summary:, operation: "debit", category: "rent_or_mortgage", frequency: "weekly", amount: 222.22)
        create(:regular_transaction, gross_income_summary:, operation: "credit", category: "maintenance_in", frequency: "weekly", amount: 12_000)
      end

      it "increments #<cagtegory>_all_sources data" do
        collator
        disposable_income_summary.reload
        expect(disposable_income_summary).to have_attributes(
          child_care_all_sources: 0.0,
          maintenance_out_all_sources: 481.48,
          rent_or_mortgage_all_sources: 962.95,
          legal_aid_all_sources: 0.0,
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
          create(:regular_transaction, gross_income_summary:, operation: "debit", category: "rent_or_mortgage", frequency: "monthly", amount: 2000.00)
        end

        it "increments #<cagtegory>_all_sources data to existing values" do
          collator
          disposable_income_summary.reload
          expect(disposable_income_summary).to have_attributes(
            child_care_all_sources: 0.0,
            maintenance_out_all_sources: 1_333.33,
            rent_or_mortgage_all_sources: 2_000.00,
            legal_aid_all_sources: 0.0,
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

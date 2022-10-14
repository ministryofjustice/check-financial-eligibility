require "rails_helper"

RSpec.describe Collators::RegularIncomeCollator do
  let(:assessment) { create(:assessment, :with_applicant, :with_gross_income_summary) }
  let(:gross_income_summary) { assessment.gross_income_summary }

  describe ".call" do
    subject(:collator) { described_class.call(assessment) }

    context "without regular transactions" do
      it "does not increment #<cagtegory>_all_sources data" do
        collator
        gross_income_summary.reload
        expect(gross_income_summary).to have_attributes(
          benefits_all_sources: 0.0,
          maintenance_in_all_sources: 0.0,
          pension_all_sources: 0.0,
          friends_or_family_all_sources: 0.0,
          property_or_lodger_all_sources: 0.0,
        )
      end

      it "does not increment #total_gross_income" do
        expect(gross_income_summary.total_gross_income).to be_zero
      end
    end

    context "with housing_benefit regular transactions" do
      before do
        create(:regular_transaction, gross_income_summary:, operation: "credit", category: "housing_benefit", frequency: "three_monthly", amount: 1000.0)
      end

      it "does not increment #<cagtegory>_all_sources data" do
        collator
        gross_income_summary.reload
        expect(gross_income_summary).to have_attributes(
          benefits_all_sources: 0.0,
          maintenance_in_all_sources: 0.0,
          pension_all_sources: 0.0,
          friends_or_family_all_sources: 0.0,
          property_or_lodger_all_sources: 0.0,
        )
      end

      it "does not increment #total_gross_income" do
        expect(gross_income_summary.total_gross_income).to be_zero
      end
    end

    context "with three monthly regular transactions" do
      before do
        create(:regular_transaction, gross_income_summary:, operation: "credit", category: "maintenance_in", frequency: "three_monthly", amount: 100.0)
        create(:regular_transaction, gross_income_summary:, operation: "credit", category: "friends_or_family", frequency: "three_monthly", amount: 200.0)
        create(:regular_transaction, gross_income_summary:, operation: "debit", category: "maintenance_out", frequency: "three_monthly", amount: 12_000)
      end

      it "increments #<cagtegory>_all_sources data" do
        collator
        gross_income_summary.reload
        expect(gross_income_summary).to have_attributes(
          benefits_all_sources: 0.0,
          maintenance_in_all_sources: 33.33,
          pension_all_sources: 0.0,
          friends_or_family_all_sources: 66.67,
          property_or_lodger_all_sources: 0.0,
        )
      end

      it "increments #total_gross_income" do
        collator
        gross_income_summary.reload
        expect(gross_income_summary.total_gross_income).to eq 100.00
      end
    end

    context "with monthly regular transactions" do
      before do
        create(:regular_transaction, gross_income_summary:, operation: "credit", category: "maintenance_in", frequency: "monthly", amount: 111.11)
        create(:regular_transaction, gross_income_summary:, operation: "credit", category: "friends_or_family", frequency: "monthly", amount: 222.22)
        create(:regular_transaction, gross_income_summary:, operation: "debit", category: "maintenance_out", frequency: "monthly", amount: 12_000)
      end

      it "increments #<cagtegory>_all_sources data" do
        collator
        gross_income_summary.reload
        expect(gross_income_summary).to have_attributes(
          benefits_all_sources: 0.0,
          maintenance_in_all_sources: 111.11,
          pension_all_sources: 0.0,
          friends_or_family_all_sources: 222.22,
          property_or_lodger_all_sources: 0.0,
        )
      end

      it "increments #total_gross_income" do
        collator
        gross_income_summary.reload
        expect(gross_income_summary.total_gross_income).to eq 333.33
      end
    end

    context "with four_weekly regular transactions" do
      before do
        create(:regular_transaction, gross_income_summary:, operation: "credit", category: "maintenance_in", frequency: "four_weekly", amount: 111.11)
        create(:regular_transaction, gross_income_summary:, operation: "credit", category: "friends_or_family", frequency: "four_weekly", amount: 222.22)
        create(:regular_transaction, gross_income_summary:, operation: "debit", category: "maintenance_out", frequency: "four_weekly", amount: 12_000)
      end

      it "increments #<cagtegory>_all_sources data as monthly" do
        collator
        gross_income_summary.reload
        expect(gross_income_summary).to have_attributes(
          benefits_all_sources: 0.0,
          maintenance_in_all_sources: 120.37,
          pension_all_sources: 0.0,
          friends_or_family_all_sources: 240.74,
          property_or_lodger_all_sources: 0.0,
        )
      end

      it "increments #total_gross_income as monthly" do
        collator
        gross_income_summary.reload
        expect(gross_income_summary.total_gross_income).to eq 361.11
      end
    end

    context "with two_weekly regular transactions" do
      before do
        create(:regular_transaction, gross_income_summary:, operation: "credit", category: "maintenance_in", frequency: "two_weekly", amount: 111.11)
        create(:regular_transaction, gross_income_summary:, operation: "credit", category: "friends_or_family", frequency: "two_weekly", amount: 222.22)
        create(:regular_transaction, gross_income_summary:, operation: "debit", category: "maintenance_out", frequency: "two_weekly", amount: 12_000)
      end

      it "increments #<cagtegory>_all_sources data as monthly" do
        collator
        gross_income_summary.reload
        expect(gross_income_summary).to have_attributes(
          benefits_all_sources: 0.0,
          maintenance_in_all_sources: 240.74,
          pension_all_sources: 0.0,
          friends_or_family_all_sources: 481.48,
          property_or_lodger_all_sources: 0.0,
        )
      end

      it "increments #total_gross_income as monthly" do
        collator
        gross_income_summary.reload
        expect(gross_income_summary.total_gross_income).to eq 722.22
      end
    end

    context "with weekly regular transaction" do
      before do
        create(:regular_transaction, gross_income_summary:, operation: "credit", category: "maintenance_in", frequency: "weekly", amount: 111.11)
        create(:regular_transaction, gross_income_summary:, operation: "credit", category: "friends_or_family", frequency: "weekly", amount: 222.22)
        create(:regular_transaction, gross_income_summary:, operation: "debit", category: "maintenance_out", frequency: "weekly", amount: 12_000)
      end

      it "increments #<cagtegory>_all_sources data as monthly" do
        collator
        gross_income_summary.reload
        expect(gross_income_summary).to have_attributes(
          benefits_all_sources: 0.0,
          maintenance_in_all_sources: 481.48,
          pension_all_sources: 0.0,
          friends_or_family_all_sources: 962.95,
          property_or_lodger_all_sources: 0.0,
        )
      end

      it "increments #total_gross_income as monthly" do
        collator
        gross_income_summary.reload
        expect(gross_income_summary.total_gross_income).to eq 1444.43
      end
    end

    context "with multiple regular transactions of same operation and category" do
      before do
        create(:regular_transaction, gross_income_summary:, operation: "credit", category: "maintenance_in", frequency: "monthly", amount: 111.11)
        create(:regular_transaction, gross_income_summary:, operation: "credit", category: "maintenance_in", frequency: "monthly", amount: 222.22)
      end

      it "increments their values into single #<cagtegory>_all_sources data" do
        collator
        gross_income_summary.reload
        expect(gross_income_summary).to have_attributes(
          benefits_all_sources: 0.0,
          maintenance_in_all_sources: 333.33,
          pension_all_sources: 0.0,
          friends_or_family_all_sources: 0.0,
          property_or_lodger_all_sources: 0.0,
        )
      end

      it "increments #total_gross_income" do
        collator
        gross_income_summary.reload
        expect(gross_income_summary.total_gross_income).to eq 333.33
      end
    end

    context "with existing data" do
      before do
        assessment.gross_income_summary.update!(
          student_loan: 111.11,
          unspecified_source_income: 444.44,
          benefits_cash: 222.22,
          benefits_all_sources: 222.22,
          total_gross_income: 333.33,
        )
      end

      it "has expected values prior to regular income collation" do
        expect(gross_income_summary).to have_attributes(
          student_loan: 111.11,
          unspecified_source_income: 444.44,
          benefits_bank: 0.0,
          benefits_cash: 222.22,
          benefits_all_sources: 222.22,
          friends_or_family_bank: 0.0,
          friends_or_family_cash: 0.0,
          friends_or_family_all_sources: 0.0,
          total_gross_income: 333.33,
        )
      end

      context "with monthly regular transactions" do
        before do
          create(:regular_transaction, gross_income_summary:, operation: "credit", category: "benefits", frequency: "monthly", amount: 1000.00)
          create(:regular_transaction, gross_income_summary:, operation: "credit", category: "friends_or_family", frequency: "monthly", amount: 2000.00)
          create(:regular_transaction, gross_income_summary:, operation: "debit", category: "maintenance_out", frequency: "monthly", amount: 12_000)
        end

        it "increments #<cagtegory>_all_sources data against existing values" do
          collator
          gross_income_summary.reload
          expect(gross_income_summary).to have_attributes(
            benefits_all_sources: 1_222.22,
            maintenance_in_all_sources: 0.0,
            pension_all_sources: 0.0,
            friends_or_family_all_sources: 2_000.00,
            property_or_lodger_all_sources: 0.0,
          )
        end

        it "increments #total_gross_income against existing value" do
          collator
          gross_income_summary.reload
          expect(gross_income_summary.total_gross_income).to eq 3333.33
        end
      end
    end
  end
end

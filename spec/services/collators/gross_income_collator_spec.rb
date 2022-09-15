require "rails_helper"

module Collators
  RSpec.describe GrossIncomeCollator do
    let(:assessment) { create :assessment, :with_applicant, :with_gross_income_summary, proceedings: proceeding_type_codes }
    let(:gross_income_summary) { assessment.gross_income_summary }

    before do
      create :bank_holiday
      mock_lfa_responses
      assessment.proceeding_type_codes.each do |ptc|
        create :gross_income_eligibility,
               gross_income_summary:,
               proceeding_type_code: ptc,
               upper_threshold: ProceedingTypeThreshold.value_for(ptc.to_sym, :gross_income_upper, assessment.submission_date),
               assessment_result: "pending"
      end
    end

    describe ".call" do
      subject(:collator) { described_class.call assessment }

      context "only domestic abuse proceeding type codes" do
        let(:proceeding_type_codes) { [%w[DA001 A]] }

        context "monthly_other_income" do
          context "there are no other income records" do
            it "set monthly other income to zero" do
              collator
              expect(gross_income_summary.reload.monthly_other_income).to eq 0.0
            end
          end

          context "monthly_other_income_sources_exist" do
            before do
              source1 = create :other_income_source, gross_income_summary: gross_income_summary, name: "friends_or_family"
              source2 = create :other_income_source, gross_income_summary: gross_income_summary, name: "property_or_lodger"
              create :other_income_payment, other_income_source: source1, payment_date: Date.current, amount: 105.13
              create :other_income_payment, other_income_source: source1, payment_date: 1.month.ago.to_date, amount: 105.23
              create :other_income_payment, other_income_source: source1, payment_date: 1.month.ago.to_date, amount: 105.03

              create :other_income_payment, other_income_source: source2, payment_date: Date.current, amount: 66.45
              create :other_income_payment, other_income_source: source2, payment_date: 1.month.ago.to_date, amount: 66.45
              create :other_income_payment, other_income_source: source2, payment_date: 1.month.ago.to_date, amount: 66.45
            end

            it "updates the gross income record with categorised monthly incomes" do
              collator
              gross_income_summary.reload
              expect(gross_income_summary.benefits_all_sources).to be_zero
              expect(gross_income_summary.maintenance_in_all_sources).to be_zero
              expect(gross_income_summary.pension_all_sources).to be_zero
              expect(gross_income_summary.friends_or_family_all_sources).to eq 105.13
              expect(gross_income_summary.property_or_lodger_all_sources).to eq 66.45
              expect(gross_income_summary.monthly_other_income).to eq 171.58
              expect(gross_income_summary.total_gross_income).to eq 171.58
            end
          end
        end

        context "monthly_student_loan" do
          context "there are no irregular income payments" do
            it "set monthly student loan to zero" do
              collator
              expect(gross_income_summary.reload.monthly_student_loan).to eq 0.0
            end
          end

          context "monthly_student_loan exists" do
            before { create :irregular_income_payment, gross_income_summary:, amount: 12_000 }

            it "updates the gross income record with categorised monthly incomes" do
              collator
              gross_income_summary.reload
              expect(gross_income_summary.benefits_all_sources).to be_zero
              expect(gross_income_summary.maintenance_in_all_sources).to be_zero
              expect(gross_income_summary.pension_all_sources).to be_zero
              expect(gross_income_summary.monthly_other_income).to eq 0.0
              expect(gross_income_summary.monthly_student_loan).to eq 12_000 / 12
              expect(gross_income_summary.total_gross_income).to eq 12_000 / 12
            end
          end
        end

        context "bank and cash transactions" do
          let(:assessment) { create :assessment, :with_applicant, :with_gross_income_summary_and_records }

          before do
            collator
            gross_income_summary.reload
          end

          it "updates with totals for all categories based on bank and cash transactions" do
            benefits_total = gross_income_summary.benefits_bank + gross_income_summary.benefits_cash
            friends_or_family_total = gross_income_summary.friends_or_family_bank + gross_income_summary.friends_or_family_cash
            maintenance_in_total = gross_income_summary.maintenance_in_bank + gross_income_summary.maintenance_in_cash
            property_or_lodger_total = gross_income_summary.property_or_lodger_bank + gross_income_summary.property_or_lodger_cash
            pension_total = gross_income_summary.pension_bank + gross_income_summary.pension_cash

            expect(gross_income_summary.benefits_all_sources).to eq benefits_total
            expect(gross_income_summary.friends_or_family_all_sources).to eq friends_or_family_total
            expect(gross_income_summary.maintenance_in_all_sources).to eq maintenance_in_total
            expect(gross_income_summary.property_or_lodger_all_sources).to eq property_or_lodger_total
            expect(gross_income_summary.pension_all_sources).to eq pension_total
          end

          it "has a total gross income based on all sources and monthly student loan" do
            all_sources_total = gross_income_summary.benefits_all_sources +
              gross_income_summary.friends_or_family_all_sources +
              gross_income_summary.maintenance_in_all_sources +
              gross_income_summary.property_or_lodger_all_sources +
              gross_income_summary.pension_all_sources +
              gross_income_summary.monthly_student_loan

            expect(gross_income_summary.total_gross_income).to eq all_sources_total
          end
        end

        context "gross_employment_income" do
          let(:assessment) { create :assessment, :with_applicant, :with_gross_income_summary_and_employment, :with_disposable_income_summary }
          let(:displosable_income_summary) { assessment.disposable_income_summary }

          before do
            collator
            gross_income_summary.reload
            displosable_income_summary.reload
          end

          it "has a total gross employed income" do
            expect(gross_income_summary.gross_employment_income).to eq 1500
          end

          it "updates disposable income summary" do
            expect(displosable_income_summary.employment_income_deductions).to eq(-645)
            expect(displosable_income_summary.tax).to eq(-495)
            expect(displosable_income_summary.national_insurance).to eq(-150)
            expect(displosable_income_summary.fixed_employment_allowance).to eq(-45)
          end
        end
      end
    end
  end
end

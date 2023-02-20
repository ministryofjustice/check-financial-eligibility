require "rails_helper"

module Collators
  RSpec.describe GrossIncomeCollator do
    let(:assessment) { create :assessment, :with_applicant, :with_gross_income_summary, proceedings: proceeding_type_codes }
    let(:gross_income_summary) { assessment.gross_income_summary }

    before do
      create :bank_holiday
      assessment.proceeding_type_codes.each do |ptc|
        create :gross_income_eligibility,
               gross_income_summary:,
               proceeding_type_code: ptc,
               assessment_result: "pending"
      end
    end

    describe ".call" do
      subject(:collator) do
        described_class.call assessment:,
                             submission_date: assessment.submission_date,
                             employments: assessment.employments,
                             disposable_income_summary: assessment.disposable_income_summary,
                             gross_income_summary: assessment.gross_income_summary
      end

      context "only domestic abuse proceeding type codes" do
        let(:proceeding_type_codes) { [%w[DA001 A]] }

        context "monthly_other_income" do
          context "there are no other income records" do
            it "set monthly other income to zero" do
              response = collator
              expect(response.monthly_unspecified_source).to eq 0.0
              expect(response.monthly_student_loan).to eq 0.0
            end
          end

          context "monthly_other_income_sources_exist" do
            before do
              source1 = create :other_income_source, gross_income_summary:, name: "friends_or_family"
              source2 = create :other_income_source, gross_income_summary:, name: "property_or_lodger"
              create :other_income_payment, other_income_source: source1, payment_date: Date.current, amount: 105.13
              create :other_income_payment, other_income_source: source1, payment_date: 1.month.ago.to_date, amount: 105.23
              create :other_income_payment, other_income_source: source1, payment_date: 1.month.ago.to_date, amount: 105.03

              create :other_income_payment, other_income_source: source2, payment_date: Date.current, amount: 66.45
              create :other_income_payment, other_income_source: source2, payment_date: 1.month.ago.to_date, amount: 66.45
              create :other_income_payment, other_income_source: source2, payment_date: 1.month.ago.to_date, amount: 66.45
            end

            it "updates the gross income record with categorised monthly incomes" do
              response = collator
              expect(response.monthly_regular_incomes(:all_sources, :benefits)).to be_zero
              expect(response.monthly_regular_incomes(:all_sources, :maintenance_in)).to be_zero
              expect(response.monthly_regular_incomes(:all_sources, :pension)).to be_zero
              expect(response.monthly_regular_incomes(:all_sources, :friends_or_family)).to eq 105.13
              expect(response.monthly_regular_incomes(:all_sources, :property_or_lodger)).to eq 66.45
              expect(response.total_gross_income).to eq 171.58
            end
          end
        end

        context "monthly_student_loan" do
          context "there are no irregular income payments" do
            it "set monthly student loan to zero" do
              response = collator
              expect(response.monthly_student_loan).to eq 0.0
            end
          end

          context "monthly_student_loan exists" do
            before { create :irregular_income_payment, gross_income_summary:, amount: 12_000 }

            it "updates the gross income record with categorised monthly incomes" do
              response = collator
              expect(response.monthly_regular_incomes(:all_sources, :benefits)).to be_zero
              expect(response.monthly_regular_incomes(:all_sources, :maintenance_in)).to be_zero
              expect(response.monthly_regular_incomes(:all_sources, :pension)).to be_zero
              expect(response.monthly_student_loan).to eq 12_000 / 12
              expect(response.total_gross_income).to eq 12_000 / 12
            end
          end
        end

        context "monthly_unspecified_source" do
          context "there are no irregular income payments" do
            it "set monthly income from unspecified sources to zero" do
              response = collator
              expect(response.monthly_unspecified_source).to eq 0.0
            end
          end

          context "monthly_unspecified_source exists" do
            before do
              create :irregular_income_payment,
                     gross_income_summary:,
                     amount: 12_000,
                     income_type: "unspecified_source",
                     frequency: "quarterly"
            end

            it "updates the gross income record with categorised monthly incomes" do
              response = collator
              expect(response.monthly_regular_incomes(:all_sources, :benefits)).to be_zero
              expect(response.monthly_regular_incomes(:all_sources, :maintenance_in)).to be_zero
              expect(response.monthly_regular_incomes(:all_sources, :pension)).to be_zero
              expect(response.monthly_unspecified_source).to eq 12_000 / 3
              expect(response.total_gross_income).to eq 12_000 / 3
            end
          end
        end

        context "bank and cash transactions" do
          let(:assessment) { create :assessment, :with_applicant, :with_gross_income_summary_and_records }

          it "updates with totals for all categories based on bank and cash transactions" do
            response = collator
            expect(response.monthly_regular_incomes(:all_sources, :benefits)).to eq(
              response.monthly_regular_incomes(:cash, :benefits) + response.monthly_regular_incomes(:bank, :benefits),
            )
            expect(response.monthly_regular_incomes(:all_sources, :friends_or_family)).to eq(
              response.monthly_regular_incomes(:cash, :friends_or_family) + response.monthly_regular_incomes(:bank, :friends_or_family),
            )
            expect(response.monthly_regular_incomes(:all_sources, :maintenance_in)).to eq(
              response.monthly_regular_incomes(:cash, :maintenance_in) + response.monthly_regular_incomes(:bank, :maintenance_in),
            )
            expect(response.monthly_regular_incomes(:all_sources, :property_or_lodger)).to eq(
              response.monthly_regular_incomes(:cash, :property_or_lodger) + response.monthly_regular_incomes(:bank, :property_or_lodger),
            )
            expect(response.monthly_regular_incomes(:all_sources, :pension)).to eq(
              response.monthly_regular_incomes(:cash, :pension) + response.monthly_regular_incomes(:bank, :pension),
            )
          end

          it "has a total gross income based on all sources and monthly student loan" do
            response = collator
            all_sources_total = response.monthly_regular_incomes(:all_sources, :benefits) +
              response.monthly_regular_incomes(:all_sources, :friends_or_family) +
              response.monthly_regular_incomes(:all_sources, :maintenance_in) +
              response.monthly_regular_incomes(:all_sources, :property_or_lodger) +
              response.monthly_regular_incomes(:all_sources, :pension) +
              response.monthly_student_loan +
              response.monthly_unspecified_source

            expect(response.total_gross_income).to eq all_sources_total
          end
        end

        context "gross_employment_income" do
          let(:assessment) { create :assessment, :with_applicant, :with_gross_income_summary_and_employment, :with_disposable_income_summary }
          let(:disposable_income_summary) { assessment.disposable_income_summary }

          it "has a total gross employed income" do
            response = collator
            expect(response.employment_income_subtotals.gross_employment_income).to eq 1500
          end

          it "updates disposable income summary" do
            collator
            disposable_income_summary.reload
            expect(disposable_income_summary.employment_income_deductions).to eq(-645)
            expect(disposable_income_summary.tax).to eq(-495)
            expect(disposable_income_summary.national_insurance).to eq(-150)
            expect(disposable_income_summary.fixed_employment_allowance).to eq(-45)
          end
        end
      end
    end
  end
end

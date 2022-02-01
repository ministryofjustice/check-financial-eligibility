require "rails_helper"

module Collators
  RSpec.describe ChildcareCollator do
    describe ".call" do
      let(:assessment) { create :assessment, :with_disposable_income_summary, :with_gross_income_summary }
      let(:disposable_income_summary) { assessment.disposable_income_summary }
      let(:gross_income_summary) { assessment.gross_income_summary }
      let(:target_time) { Date.current }

      subject(:collator) { described_class.call(assessment) }

      before do
        travel_to target_time
        create :bank_holiday
        create :childcare_outgoing, disposable_income_summary: disposable_income_summary, payment_date: Date.yesterday, amount: 155.63
        create :childcare_outgoing, disposable_income_summary: disposable_income_summary, payment_date: 1.month.ago, amount: 155.63
        create :childcare_outgoing, disposable_income_summary: disposable_income_summary, payment_date: 2.months.ago, amount: 155.63
      end

      context "No dependants under 15" do
        before do
          create :dependant, assessment: assessment, date_of_birth: 16.years.ago
        end

        context "Employed" do
          before { allow_any_instance_of(described_class).to receive(:applicant_employed?).and_return(true) }

          context "in receipt of Student grant in irregular income payments" do
            before { create :irregular_income_payment, gross_income_summary: gross_income_summary }

            it "does not update the childcare value on the disposable income summary" do
              collator
              expect(disposable_income_summary.childcare).to eq 0.0
            end
          end

          context "not in receipt of Student grant" do
            it "does not update the childcare value on the disposable income summary" do
              collator
              expect(disposable_income_summary.childcare).to eq 0.0
            end
          end
        end

        context "not employed" do
          context "in receipt of Student grant" do
            context "in irregular income payments" do
              before { create :irregular_income_payment, gross_income_summary: gross_income_summary }

              it "does not update the childcare value on the disposable income summary" do
                collator
                expect(disposable_income_summary.childcare).to eq 0.0
              end
            end
          end

          context "not in receipt of Student grant" do
            it "does not update the childcare value on the disposable income summary" do
              collator
              expect(disposable_income_summary.childcare).to eq 0.0
            end
          end
        end
      end

      context "a dependant under 15" do
        let(:target_time) { Time.zone.local(2021, 4, 11) }

        before do
          create :dependant, assessment: assessment, date_of_birth: 16.years.ago
          create :dependant, assessment: assessment, date_of_birth: 14.years.ago
        end

        context "Employed" do
          before { allow_any_instance_of(described_class).to receive(:applicant_employed?).and_return(true) }

          context "in receipt of Student grant in irregular income payments" do
            before { create :irregular_income_payment, gross_income_summary: gross_income_summary }

            it "updates the childcare value on the disposable income summary" do
              collator
              expect(disposable_income_summary.child_care_bank).to eq 155.63
            end
          end

          context "not in receipt of Student grant" do
            it "updates the childcare value on the disposable income summary" do
              collator
              expect(disposable_income_summary.child_care_bank).to eq 155.63
            end
          end
        end

        context "not employed" do
          context "in receipt of Student grant in irregular income payments" do
            before { create :irregular_income_payment, amount: 0.0, gross_income_summary: gross_income_summary }

            it "updates the childcare value on the disposable income summary" do
              collator
              expect(disposable_income_summary.child_care_bank).to eq 155.63
            end
          end

          context "not in receipt of Student grant" do
            before { create :other_income_source, gross_income_summary: gross_income_summary, name: "friends_or_family" }

            it "does not update the childcare value on the disposable income summary" do
              collator
              expect(disposable_income_summary.child_care_bank).to eq 0.0
            end
          end
        end
      end
    end
  end
end

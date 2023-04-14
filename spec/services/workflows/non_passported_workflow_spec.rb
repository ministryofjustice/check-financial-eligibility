require "rails_helper"

module Workflows
  RSpec.describe NonPassportedWorkflow do
    let(:assessment) do
      create :assessment, :with_capital_summary, :with_disposable_income_summary,
             :with_gross_income_summary,
             submission_date: Date.new(2022, 6, 7),
             applicant:, proceedings: proceeding_types.map { |p| [p, "A"] }, level_of_help:
    end

    before do
      assessment.proceeding_type_codes.each do |ptc|
        create :gross_income_eligibility, gross_income_summary: assessment.gross_income_summary, proceeding_type_code: ptc
        create :disposable_income_eligibility, disposable_income_summary: assessment.disposable_income_summary,
                                               lower_threshold: 500,
                                               proceeding_type_code: ptc
      end
      Creators::CapitalEligibilityCreator.call(assessment)
    end

    describe "#call", :calls_bank_holiday do
      let(:level_of_help) { "certificated" }
      let(:proceeding_types) { %w[SE003] }

      subject(:assessment_result) do
        assessment.reload
        described_class.call(assessment)
        Assessors::MainAssessor.call(assessment)
        assessment.assessment_result
      end

      before do
        assessment.proceeding_type_codes.each do |ptc|
          create(:assessment_eligibility, assessment:, proceeding_type_code: ptc)
        end
      end

      context "when self_employed" do
        let(:applicant) { build :applicant, self_employed: true }

        it "calls the self-employed workflow" do
          expect(SelfEmployedWorkflow).to receive(:call).with(assessment)
          described_class.call(assessment)
        end
      end

      describe "capital thresholds for controlled" do
        let(:level_of_help) { "controlled" }
        let(:applicant) { build :applicant, :under_pensionable_age, self_employed: false }

        before do
          create(:property, :additional_property, capital_summary: assessment.capital_summary,
                                                  value: property_value, outstanding_mortgage: 0, percentage_owned: 100)
        end

        context "with 8k capital" do
          let(:property_value) { 8_000 }

          it "is eligible" do
            expect(assessment_result).to eq("eligible")
          end
        end

        context "with a first-tier immigration case" do
          let(:proceeding_types) { [CFEConstants::IMMIGRATION_PROCEEDING_TYPE_CCMS_CODE] }

          context "with 8k capital" do
            let(:property_value) { 8_000 }

            it "is ineligible" do
              expect(assessment_result).to eq("ineligible")
            end
          end

          context "with 3k capital" do
            let(:property_value) { 3_000 }

            it "is eligible" do
              expect(assessment_result).to eq("eligible")
            end
          end
        end
      end

      context "with capital" do
        before do
          create(:property, :additional_property, capital_summary: assessment.capital_summary,
                                                  value: 170_000, outstanding_mortgage: 100_000, percentage_owned: 100)
        end

        context "without partner" do
          let(:applicant) { build :applicant, :under_pensionable_age, self_employed: false }

          it "is not eligible" do
            expect(assessment_result).to eq("ineligible")
          end
        end

        context "with pensionable partner" do
          let(:applicant) { build :applicant, :under_pensionable_age, self_employed: false }

          before do
            create(:partner, :over_pensionable_age, assessment:)
          end

          it "is eligible" do
            expect(assessment_result).to eq("eligible")
          end
        end

        context "when both pensioners" do
          let(:applicant) { build :applicant, :over_pensionable_age, self_employed: false }

          before do
            create(:partner, :over_pensionable_age, assessment:)
            create(:property, :additional_property, capital_summary: assessment.partner_capital_summary,
                                                    value: 170_000, outstanding_mortgage: 100_000, percentage_owned: 100)
          end

          it "doesnt double-count" do
            expect(assessment_result).to eq("ineligible")
          end
        end
      end

      context "without capital" do
        let(:applicant) { build :applicant, :over_pensionable_age, self_employed: false, employed: }

        context "with childcare costs (and at least 1 dependent child)" do
          let(:salary) { 19_000 }

          before do
            create(:child_care_transaction_category,
                   gross_income_summary: assessment.gross_income_summary,
                   cash_transactions: build_list(:cash_transaction, 1, amount: 800))
            create(:dependant, :under15, assessment:)
          end

          context "when employed" do
            let(:employed) { true }

            before do
              create(:employment, :with_monthly_payments, assessment:, gross_monthly_income: salary / 12.0)
            end

            it "is eligible" do
              expect(assessment_result).to eq("eligible")
            end
          end

          context "when unemployed with partner" do
            let(:employed) { false }

            context "with partner employment" do
              before do
                create(:partner, assessment:, employed: true)
                create(:employment, :with_monthly_payments, assessment:, gross_monthly_income: salary / 12.0)
              end

              it "is eligible" do
                expect(assessment_result).to eq("eligible")
              end
            end

            context "with partner student loan" do
              before do
                create(:partner, assessment:, employed: false)
                create(:student_loan_payment, gross_income_summary: assessment.reload.partner_gross_income_summary)
              end

              it "is eligible" do
                expect(assessment_result).to eq("eligible")
              end
            end
          end
        end

        context "with housing costs" do
          let(:employed) { true }

          before do
            create(:employment, :with_monthly_payments, assessment:,
                                                        gross_monthly_income: 3_000)
            create(:housing_cost, amount: 1000,
                                  gross_income_summary: assessment.gross_income_summary)
          end

          it "is not eligible due to housing cost cap" do
            expect(assessment_result).to eq("contribution_required")
          end

          context "with partner" do
            before do
              create(:partner, assessment:)
              create(:gross_income_summary, assessment:, type: "PartnerGrossIncomeSummary")
              create(:disposable_income_summary, assessment:, type: "PartnerDisposableIncomeSummary")
            end

            it "is eligible due to cap being removed" do
              expect(assessment_result).to eq("eligible")
            end
          end
        end

        context "with employment" do
          let(:salary) { 15_300 }

          context "when unemployed" do
            let(:employed) { false }

            it "is below the theshold and thus eligible" do
              expect(assessment_result).to eq("eligible")
            end

            context "with an employed partner" do
              before do
                create(:partner, assessment:, employed: true)
                create(:partner_employment, :with_monthly_payments, assessment:, gross_monthly_income: salary / 12.0)
              end

              it "is eligible due to partner allowance" do
                expect(assessment_result).to eq("eligible")
              end
            end
          end

          context "when employed" do
            let(:employed) { true }

            before do
              create(:employment, :with_monthly_payments, assessment:, gross_monthly_income: salary / 12.0)
            end

            it "is not eligible due to income" do
              expect(assessment_result).to eq("contribution_required")
            end
          end
        end
      end
    end
  end
end

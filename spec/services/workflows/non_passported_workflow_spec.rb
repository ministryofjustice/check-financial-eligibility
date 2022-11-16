require "rails_helper"

module Workflows
  RSpec.describe NonPassportedWorkflow do
    let(:assessment) do
      create :assessment, :with_capital_summary, :with_disposable_income_summary,
             :with_gross_income_summary,
             applicant:, proceedings: [%w[SE003 A]]
    end

    before do
      assessment.proceeding_type_codes.each do |ptc|
        create :capital_eligibility, capital_summary: assessment.capital_summary, proceeding_type_code: ptc
        create :gross_income_eligibility, gross_income_summary: assessment.gross_income_summary, proceeding_type_code: ptc,
                                          upper_threshold: 20_000
        create :disposable_income_eligibility, disposable_income_summary: assessment.disposable_income_summary,
                                               lower_threshold: 500,
                                               proceeding_type_code: ptc
      end
    end

    describe ".call" do
      subject(:workflow_call) { described_class.call(assessment) }

      context "when self_employed" do
        let(:applicant) { create :applicant, self_employed: true }

        it "calls the self-employed workflow" do
          expect(SelfEmployedWorkflow).to receive(:call).with(assessment)
          workflow_call
        end
      end

      context "without capital distractions" do
        let(:applicant) { create :applicant, :over_pensionable_age, self_employed: false, employed: }
        let(:assessment_result) do
          assessment.reload
          workflow_call
          Assessors::MainAssessor.call(assessment)
          assessment.assessment_result
        end

        before do
          stub_request(:get, "https://www.gov.uk/bank-holidays.json")
            .to_return(body: file_fixture("bank-holidays.json").read)

          assessment.proceeding_type_codes.each do |ptc|
            create(:assessment_eligibility, assessment:, proceeding_type_code: ptc)
          end
        end

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

            before do
              create(:gross_income_summary, assessment:, type: "PartnerGrossIncomeSummary")
              create(:disposable_income_summary, assessment:, type: "PartnerDisposableIncomeSummary")
            end

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
            create(:employment, assessment:,
                                employment_payments: build_list(:employment_payment, 3, gross_income: 3_000))
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
                create(:partner, assessment:)
                create(:partner_employment, :with_monthly_payments, assessment:, gross_monthly_income: salary / 12.0)
              end

              it "is eligible due to partner income" do
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

      context "when not employed, not self_employed, Gross income exceeds threshold" do
        let(:applicant) { create :applicant, self_employed: false }

        before do
          assessment.gross_income_summary.eligibilities.map { |elig| elig.update! assessment_result: "ineligible" }
        end

        it "collates and assesses gross income but not disposable income" do
          expect(Collators::GrossIncomeCollator).to receive(:call)
          expect(Collators::RegularIncomeCollator).to receive(:call).with(assessment.gross_income_summary)
          expect(Assessors::GrossIncomeAssessor).to receive(:call)
          expect(Assessors::DisposableIncomeAssessor).not_to receive(:call)
          workflow_call
        end
      end

      context "when not employed, not self_employed, Gross income does not exceed threshold" do
        let(:applicant) { create :applicant, self_employed: false }

        before do
          assessment.gross_income_summary.eligibilities.map { |elig| elig.update! assessment_result: "eligible" }
        end

        it "collates and assesses outgoings, regular transations and gross income and disposable income" do
          expect(Collators::GrossIncomeCollator).to receive(:call)
          expect(Collators::RegularIncomeCollator).to receive(:call).with(assessment.gross_income_summary)
          expect(Assessors::GrossIncomeAssessor).to receive(:call)
          expect(Collators::OutgoingsCollator).to receive(:call)
          expect(Assessors::DisposableIncomeAssessor).to receive(:call)
          workflow_call
        end
      end
    end
  end
end

require "rails_helper"

module Workflows
  RSpec.describe NonPassportedWorkflow do
    let(:assessment) { create :assessment, :with_everything, applicant:, proceedings: [%w[SE003 A]] }

    before do
      assessment.proceeding_type_codes.each do |ptc|
        create :capital_eligibility, capital_summary: assessment.capital_summary, proceeding_type_code: ptc
        create :gross_income_eligibility, upper_threshold: 20_000, gross_income_summary: assessment.gross_income_summary, proceeding_type_code: ptc
        create :disposable_income_eligibility, disposable_income_summary: assessment.disposable_income_summary, proceeding_type_code: ptc
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

      context "without self employment or capital distractions" do
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

        describe "childcare costs" do
          before do
            create(:child_care_transaction_category,
                   gross_income_summary: assessment.gross_income_summary,
                   cash_transactions: build_list(:cash_transaction, 1, amount: 800))
            create(:dependant, :under15, assessment:)
          end

          context "with employment" do
            let(:employed) { true }

            before do
              create(:employment, assessment:,
                                  employment_payments: build_list(:employment_payment, 3, gross_income: 3_100))
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
                create(:partner_employment, assessment:,
                                            employment_payments: build_list(:employment_payment, 3, gross_income: 3_100))
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

        context "without employment" do
          let(:employed) { false }

          it "is below the theshold and thus eligible" do
            workflow_call
            Assessors::MainAssessor.call(assessment)
            expect(assessment.assessment_result).to eq("eligible")
          end

          context "with an employed partner" do
            before do
              create(:partner, assessment:)
              create(:employment, type: "PartnerEmployment", assessment:,
                                  employment_payments: build_list(:employment_payment, 1, gross_income: 105_000))
              create(:gross_income_summary, assessment:, type: "PartnerGrossIncomeSummary")
              create(:disposable_income_summary, assessment:, type: "PartnerDisposableIncomeSummary")
              assessment.reload
            end

            it "is ineligible due to partner income" do
              workflow_call
              Assessors::MainAssessor.call(assessment)
              expect(assessment.assessment_result).to eq("ineligible")
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

require "rails_helper"

module Assessors
  RSpec.describe AssessmentProceedingTypeAssessor do
    let(:assessment) do
      create :assessment,
             :with_capital_summary,
             :with_gross_income_summary,
             :with_disposable_income_summary,
             :with_eligibilities,
             :with_applicant,
             proceedings: [[ptc, "A"]]
    end
    let(:ptc) { "DA003" }
    let(:gross_income_eligibility) { assessment.gross_income_summary.eligibilities.find_by(proceeding_type_code: ptc) }
    let(:disposable_income_eligibility) { assessment.disposable_income_summary.eligibilities.find_by(proceeding_type_code: ptc) }
    let(:capital_eligibility) { assessment.capital_summary.eligibilities.find_by(proceeding_type_code: ptc) }
    let(:assessment_eligibility) { assessment.eligibilities.find_by(proceeding_type_code: ptc) }

    describe ".call" do
      describe "successful result" do
        context "asylum supported applicant" do
          before { assessment.applicant.update!(receives_asylum_support: true) }

          context "when using non-immigration/asylum proceeding type codes" do
            # specify assessment results in order: gross_income_eligibility, disposable_income_eligibility, capital_eligibility
            [
              [:e, :cr, :e, "contribution_required"],
              [:e, :cr, :i, "ineligible"],
              [:e, :e, :cr, "contribution_required"],
              [:e, :e, :e, "eligible"],
              [:e, :e, :i, "ineligible"],
              [:e, :i, :cr, "ineligible"],
              [:e, :i, :e, "ineligible"],
              [:e, :i, :i, "ineligible"],
              [:e, :i, :p, "ineligible"],
              [:i, :cr, :cr, "ineligible"],
              [:i, :cr, :e, "ineligible"],
              [:i, :cr, :i, "ineligible"],
              [:i, :cr, :p, "ineligible"],
              [:i, :e, :cr, "ineligible"],
              [:i, :e, :e, "ineligible"],
              [:i, :e, :i, "ineligible"],
              [:i, :e, :p, "ineligible"],
              [:i, :i, :cr, "ineligible"],
              [:i, :i, :e, "ineligible"],
              [:i, :i, :i, "ineligible"],
              [:i, :i, :p, "ineligible"],
              [:i, :p, :cr, "ineligible"],
              [:i, :p, :e, "ineligible"],
              [:i, :p, :i, "ineligible"],
              [:i, :p, :p, "ineligible"],
            ].each do |params|
              it "updates the assessment eligibility record with the correct result" do
                gross, disposable, capital, expected_result = params
                expect(setup_and_test_result(gross, disposable, capital)).to eq(expected_result), "Expected #{gross}, #{disposable}, #{capital} to give #{expected_result}"
              end
            end
          end

          context "when using immigration/asylum proceeding type codes" do
            let(:ptc) { "IM030" }

            it "returns eligible for immigration/asylum proceeding type codes" do
              described_class.call(assessment, ptc)
              expect(assessment_eligibility.assessment_result).to eq "eligible"
            end
          end
        end

        context "passported applicant" do
          before { assessment.applicant.update!(receives_qualifying_benefit: true) }

          # specify assessment results in order: gross_income_eligibility, disposable_income_eligibility, capital_eligibility
          [
            [:p, :p, :e, "eligible"],
            [:p, :p, :i, "ineligible"],
            [:p, :p, :cr, "contribution_required"],
          ].each do |params|
            it "updates the assessment eligibility record with the correct result" do
              gross, disposable, capital, expected_result = params
              expect(setup_and_test_result(gross, disposable, capital)).to eq expected_result
            end
          end
        end

        context "non-passported applicant" do
          before { assessment.applicant.update!(receives_qualifying_benefit: false) }

          # specify assessment results in order: gross_income_eligibility, disposable_income_eligibility, capital_eligibility
          [
            [:e, :cr, :e, "contribution_required"],
            [:e, :cr, :i, "ineligible"],
            [:e, :e, :cr, "contribution_required"],
            [:e, :e, :e, "eligible"],
            [:e, :e, :i, "ineligible"],
            [:e, :i, :cr, "ineligible"],
            [:e, :i, :e, "ineligible"],
            [:e, :i, :i, "ineligible"],
            [:e, :i, :p, "ineligible"],
            [:i, :cr, :cr, "ineligible"],
            [:i, :cr, :e, "ineligible"],
            [:i, :cr, :i, "ineligible"],
            [:i, :cr, :p, "ineligible"],
            [:i, :e, :cr, "ineligible"],
            [:i, :e, :e, "ineligible"],
            [:i, :e, :i, "ineligible"],
            [:i, :e, :p, "ineligible"],
            [:i, :i, :cr, "ineligible"],
            [:i, :i, :e, "ineligible"],
            [:i, :i, :i, "ineligible"],
            [:i, :i, :p, "ineligible"],
            [:i, :p, :cr, "ineligible"],
            [:i, :p, :e, "ineligible"],
            [:i, :p, :i, "ineligible"],
            [:i, :p, :p, "ineligible"],
          ].each do |params|
            it "updates the assessment eligibility record with the correct result" do
              gross, disposable, capital, expected_result = params
              expect(setup_and_test_result(gross, disposable, capital)).to eq(expected_result), "Expected #{gross}, #{disposable}, #{capital} to give #{expected_result}"
            end
          end
        end
      end

      describe "invalid assessment_results on summary records" do
        context "passported applicant" do
          before { assessment.applicant.update!(receives_qualifying_benefit: true) }

          it "raises the expected error" do
            # specify assessment results in order: gross_income_eligibility, disposable_income_eligibility, capital_eligibility
            expect(setup_and_test_error(:e, :cr, :cr)).to eq "Invalid assessment status: for passported applicant"
            expect(setup_and_test_error(:e, :cr, :e)).to eq "Invalid assessment status: for passported applicant"
            expect(setup_and_test_error(:e, :cr, :i)).to eq "Invalid assessment status: for passported applicant"
            expect(setup_and_test_error(:e, :cr, :p)).to eq "Assessment not complete: Capital assessment still pending"
            expect(setup_and_test_error(:e, :e, :cr)).to eq "Invalid assessment status: for passported applicant"
            expect(setup_and_test_error(:e, :e, :e)).to eq "Invalid assessment status: for passported applicant"
            expect(setup_and_test_error(:e, :e, :i)).to eq "Invalid assessment status: for passported applicant"
            expect(setup_and_test_error(:e, :e, :p)).to eq "Assessment not complete: Capital assessment still pending"
            expect(setup_and_test_error(:e, :i, :cr)).to eq "Invalid assessment status: for passported applicant"
            expect(setup_and_test_error(:e, :i, :e)).to eq "Invalid assessment status: for passported applicant"
            expect(setup_and_test_error(:e, :i, :i)).to eq "Invalid assessment status: for passported applicant"
            expect(setup_and_test_error(:e, :i, :p)).to eq "Assessment not complete: Capital assessment still pending"
            expect(setup_and_test_error(:e, :p, :cr)).to eq "Invalid assessment status: for passported applicant"
            expect(setup_and_test_error(:e, :p, :e)).to eq "Invalid assessment status: for passported applicant"
            expect(setup_and_test_error(:e, :p, :i)).to eq "Invalid assessment status: for passported applicant"
            expect(setup_and_test_error(:e, :p, :p)).to eq "Assessment not complete: Capital assessment still pending"
            expect(setup_and_test_error(:i, :cr, :cr)).to eq "Invalid assessment status: for passported applicant"
            expect(setup_and_test_error(:i, :cr, :e)).to eq "Invalid assessment status: for passported applicant"
            expect(setup_and_test_error(:i, :cr, :i)).to eq "Invalid assessment status: for passported applicant"
            expect(setup_and_test_error(:i, :cr, :p)).to eq "Assessment not complete: Capital assessment still pending"
            expect(setup_and_test_error(:i, :e, :cr)).to eq "Invalid assessment status: for passported applicant"
            expect(setup_and_test_error(:i, :e, :e)).to eq "Invalid assessment status: for passported applicant"
            expect(setup_and_test_error(:i, :e, :i)).to eq "Invalid assessment status: for passported applicant"
            expect(setup_and_test_error(:i, :e, :p)).to eq "Assessment not complete: Capital assessment still pending"
            expect(setup_and_test_error(:i, :i, :cr)).to eq "Invalid assessment status: for passported applicant"
            expect(setup_and_test_error(:i, :i, :e)).to eq "Invalid assessment status: for passported applicant"
            expect(setup_and_test_error(:i, :i, :i)).to eq "Invalid assessment status: for passported applicant"
            expect(setup_and_test_error(:i, :i, :p)).to eq "Assessment not complete: Capital assessment still pending"
            expect(setup_and_test_error(:i, :p, :cr)).to eq "Invalid assessment status: for passported applicant"
            expect(setup_and_test_error(:i, :p, :e)).to eq "Invalid assessment status: for passported applicant"
            expect(setup_and_test_error(:i, :p, :i)).to eq "Invalid assessment status: for passported applicant"
            expect(setup_and_test_error(:i, :p, :p)).to eq "Assessment not complete: Capital assessment still pending"
            expect(setup_and_test_error(:p, :cr, :cr)).to eq "Invalid assessment status: for passported applicant"
            expect(setup_and_test_error(:p, :cr, :e)).to eq "Invalid assessment status: for passported applicant"
            expect(setup_and_test_error(:p, :cr, :i)).to eq "Invalid assessment status: for passported applicant"
            expect(setup_and_test_error(:p, :cr, :p)).to eq "Assessment not complete: Capital assessment still pending"
            expect(setup_and_test_error(:p, :e, :cr)).to eq "Invalid assessment status: for passported applicant"
            expect(setup_and_test_error(:p, :e, :e)).to eq "Invalid assessment status: for passported applicant"
            expect(setup_and_test_error(:p, :e, :i)).to eq "Invalid assessment status: for passported applicant"
            expect(setup_and_test_error(:p, :e, :p)).to eq "Assessment not complete: Capital assessment still pending"
            expect(setup_and_test_error(:p, :i, :cr)).to eq "Invalid assessment status: for passported applicant"
            expect(setup_and_test_error(:p, :i, :e)).to eq "Invalid assessment status: for passported applicant"
            expect(setup_and_test_error(:p, :i, :i)).to eq "Invalid assessment status: for passported applicant"
            expect(setup_and_test_error(:p, :i, :p)).to eq "Assessment not complete: Capital assessment still pending"
          end
        end

        context "non_passported_applicant" do
          before { assessment.applicant.update!(receives_qualifying_benefit: false) }

          it "raises the expected error" do
            # specify assessment results in order: gross_income_eligibility, disposable_income_eligibility, capital_eligibility
            expect(setup_and_test_error(:e, :e, :p)).to eq "Assessment not complete: Capital assessment still pending"
            expect(setup_and_test_error(:e, :p, :cr)).to eq "Assessment not complete: Disposable Income assessment still pending"
            expect(setup_and_test_error(:e, :p, :e)).to eq "Assessment not complete: Disposable Income assessment still pending"
            expect(setup_and_test_error(:e, :p, :i)).to eq "Assessment not complete: Disposable Income assessment still pending"
            expect(setup_and_test_error(:e, :p, :p)).to eq "Assessment not complete: Disposable Income assessment still pending"
            expect(setup_and_test_error(:p, :cr, :cr)).to eq "Assessment not complete: Gross Income assessment still pending"
            expect(setup_and_test_error(:p, :cr, :e)).to eq "Assessment not complete: Gross Income assessment still pending"
            expect(setup_and_test_error(:p, :cr, :i)).to eq "Assessment not complete: Gross Income assessment still pending"
            expect(setup_and_test_error(:p, :cr, :p)).to eq "Assessment not complete: Gross Income assessment still pending"
            expect(setup_and_test_error(:p, :e, :cr)).to eq "Assessment not complete: Gross Income assessment still pending"
            expect(setup_and_test_error(:p, :e, :e)).to eq "Assessment not complete: Gross Income assessment still pending"
            expect(setup_and_test_error(:p, :e, :i)).to eq "Assessment not complete: Gross Income assessment still pending"
            expect(setup_and_test_error(:p, :e, :p)).to eq "Assessment not complete: Gross Income assessment still pending"
            expect(setup_and_test_error(:p, :i, :cr)).to eq "Assessment not complete: Gross Income assessment still pending"
            expect(setup_and_test_error(:p, :i, :e)).to eq "Assessment not complete: Gross Income assessment still pending"
            expect(setup_and_test_error(:p, :i, :i)).to eq "Assessment not complete: Gross Income assessment still pending"
            expect(setup_and_test_error(:p, :i, :p)).to eq "Assessment not complete: Gross Income assessment still pending"
            expect(setup_and_test_error(:p, :p, :cr)).to eq "Assessment not complete: Gross Income assessment still pending"
            expect(setup_and_test_error(:p, :p, :e)).to eq "Assessment not complete: Gross Income assessment still pending"
            expect(setup_and_test_error(:p, :p, :i)).to eq "Assessment not complete: Gross Income assessment still pending"
            expect(setup_and_test_error(:p, :p, :p)).to eq "Assessment not complete: Gross Income assessment still pending"
          end
        end
      end

      def setup_and_test_error(gross_income_result, disposable_income_result, capital_summary_result)
        capital_eligibility.update!(assessment_result: transform_result(capital_summary_result))
        gross_income_eligibility.update!(assessment_result: transform_result(gross_income_result))
        disposable_income_eligibility.update!(assessment_result: transform_result(disposable_income_result))

        begin
          described_class.call(assessment, ptc)
        rescue StandardError => e
          raise "Unexpected exception: #{e.class}" unless e.is_a?(Assessors::AssessmentProceedingTypeAssessor::AssessmentError)

          return e.message
        end
        nil
      end

      def setup_and_test_result(gross_income_result, disposable_income_result, capital_summary_result)
        capital_eligibility.update!(assessment_result: transform_result(capital_summary_result))
        gross_income_eligibility.update!(assessment_result: transform_result(gross_income_result))
        disposable_income_eligibility.update!(assessment_result: transform_result(disposable_income_result))

        described_class.call(assessment, ptc)
        assessment_eligibility.assessment_result
      end

      def transform_result(result)
        case result
        when :e
          "eligible"
        when :cr
          "contribution_required"
        when :i
          "ineligible"
        when :p
          "pending"
        else
          raise "Invalid assessement result specified"
        end
      end
    end
  end
end

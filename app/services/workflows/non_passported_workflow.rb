module Workflows
  class NonPassportedWorkflow
    class << self
      def call(assessment)
        new(assessment).call
      end
    end

    def initialize(assessment)
      @assessment = assessment
    end

    def call
      return SelfEmployedWorkflow.call(assessment) if assessment.applicant.self_employed?

      gross_income_subtotals = collate_and_assess_gross_income
      return CalculationOutput.new(gross_income_subtotals:) if assessment.gross_income_summary.ineligible?

      disposable_income_subtotals = disposable_income_assessment(gross_income_subtotals)
      return CalculationOutput.new(gross_income_subtotals:, disposable_income_subtotals:) if assessment.disposable_income_summary.ineligible?

      capital_subtotals = collate_and_assess_capital
      CalculationOutput.new(capital_subtotals:, gross_income_subtotals:, disposable_income_subtotals:)
    end

  private

    attr_reader :assessment

    def collate_and_assess_gross_income
      applicant_gross_income_subtotals = Collators::GrossIncomeCollator.call(assessment:,
                                                                             submission_date: assessment.submission_date,
                                                                             employments: assessment.employments,
                                                                             disposable_income_summary: assessment.disposable_income_summary,
                                                                             gross_income_summary: assessment.gross_income_summary)
      if assessment.partner.present?
        partner_gross_income_subtotals = Collators::GrossIncomeCollator.call(assessment:,
                                                                             submission_date: assessment.submission_date,
                                                                             employments: assessment.partner_employments,
                                                                             disposable_income_summary: assessment.partner_disposable_income_summary,
                                                                             gross_income_summary: assessment.partner_gross_income_summary)
      end

      GrossIncomeSubtotals.new(
        applicant_gross_income_subtotals:,
        partner_gross_income_subtotals:,
      ).tap do |gross_income_subtotals|
        Assessors::GrossIncomeAssessor.call(
          eligibilities: assessment.gross_income_summary.eligibilities,
          total_gross_income: gross_income_subtotals.combined_monthly_gross_income,
        )
      end
    end

    def disposable_income_assessment(gross_income_subtotals)
      result = if assessment.partner.present?
                 partner_disposable_income_assessment(gross_income_subtotals)
               else
                 single_disposable_income_assessment(gross_income_subtotals)
               end
      result.tap do
        Assessors::DisposableIncomeAssessor.call(disposable_income_summary: assessment.disposable_income_summary,
                                                 total_disposable_income: assessment.disposable_income_summary.combined_total_disposable_income)
      end
    end

    # TODO: make the Collators::DisposableIncomeCollator increment/sum to existing values so order of "collation" becomes unimportant
    def partner_disposable_income_assessment(gross_income_subtotals)
      applicant = PersonWrapper.new person: assessment.applicant, is_single: false,
                                    dependants: assessment.dependants, gross_income_summary: assessment.gross_income_summary
      partner = PersonWrapper.new person: assessment.partner, is_single: false,
                                  dependants: assessment.partner_dependants, gross_income_summary: assessment.partner_gross_income_summary
      eligible_for_childcare = calculate_childcare_eligibility(applicant, partner)
      outgoings = Collators::OutgoingsCollator.call(submission_date: assessment.submission_date,
                                                    person: applicant,
                                                    gross_income_summary: assessment.gross_income_summary.freeze,
                                                    disposable_income_summary: assessment.disposable_income_summary,
                                                    eligible_for_childcare:,
                                                    allow_negative_net: true)
      partner_outgoings = Collators::OutgoingsCollator.call(submission_date: assessment.submission_date,
                                                            person: partner,
                                                            gross_income_summary: assessment.partner_gross_income_summary.freeze,
                                                            disposable_income_summary: assessment.partner_disposable_income_summary,
                                                            eligible_for_childcare:,
                                                            allow_negative_net: true)

      Collators::DisposableIncomeCollator.call(gross_income_summary: assessment.gross_income_summary.freeze,
                                               disposable_income_summary: assessment.disposable_income_summary,
                                               partner_allowance:,
                                               gross_income_subtotals: gross_income_subtotals.applicant_gross_income_subtotals,
                                               outgoings:)
      Collators::DisposableIncomeCollator.call(gross_income_summary: assessment.partner_gross_income_summary.freeze,
                                               disposable_income_summary: assessment.partner_disposable_income_summary,
                                               partner_allowance: 0,
                                               gross_income_subtotals: gross_income_subtotals.partner_gross_income_subtotals,
                                               outgoings: partner_outgoings)

      Collators::RegularOutgoingsCollator.call(gross_income_summary: assessment.gross_income_summary.freeze,
                                               disposable_income_summary: assessment.disposable_income_summary,
                                               eligible_for_childcare:)
      Collators::RegularOutgoingsCollator.call(gross_income_summary: assessment.partner_gross_income_summary.freeze,
                                               disposable_income_summary: assessment.partner_disposable_income_summary,
                                               eligible_for_childcare:)

      assessment.disposable_income_summary.update!(
        combined_total_disposable_income: assessment.disposable_income_summary.total_disposable_income +
                                            assessment.partner_disposable_income_summary.total_disposable_income,
        combined_total_outgoings_and_allowances: assessment.disposable_income_summary.total_outgoings_and_allowances +
                                                   assessment.partner_disposable_income_summary.total_outgoings_and_allowances,
      )
      DisposableIncomeSubtotals.new(dependant_allowance: outgoings.dependant_allowance,
                                    partner_dependant_allowance: partner_outgoings.dependant_allowance)
    end

    def single_disposable_income_assessment(gross_income_subtotals)
      applicant = PersonWrapper.new person: assessment.applicant, is_single: true,
                                    dependants: assessment.dependants, gross_income_summary: assessment.gross_income_summary
      eligible_for_childcare = calculate_childcare_eligibility(applicant)
      outgoings = Collators::OutgoingsCollator.call(submission_date: assessment.submission_date,
                                                    person: applicant,
                                                    gross_income_summary: assessment.gross_income_summary.freeze,
                                                    disposable_income_summary: assessment.disposable_income_summary,
                                                    eligible_for_childcare:,
                                                    allow_negative_net: false)
      Collators::DisposableIncomeCollator.call(gross_income_summary: assessment.gross_income_summary.freeze,
                                               disposable_income_summary: assessment.disposable_income_summary,
                                               partner_allowance: 0,
                                               gross_income_subtotals: gross_income_subtotals.applicant_gross_income_subtotals,
                                               outgoings:)
      Collators::RegularOutgoingsCollator.call(gross_income_summary: assessment.gross_income_summary.freeze,
                                               disposable_income_summary: assessment.disposable_income_summary,
                                               eligible_for_childcare:)
      assessment.disposable_income_summary.update!(combined_total_disposable_income: assessment.disposable_income_summary.total_disposable_income,
                                                   combined_total_outgoings_and_allowances: assessment.disposable_income_summary.total_outgoings_and_allowances)
      DisposableIncomeSubtotals.new(dependant_allowance: outgoings.dependant_allowance)
    end

    def collate_and_assess_capital
      CapitalCollatorAndAssessor.call assessment
    end

    def calculate_childcare_eligibility(applicant, partner = nil)
      Calculators::ChildcareEligibilityCalculator.call(
        applicant:,
        partner:,
        dependants: Dependant.where(assessment:), # Ensure we consider both client and partner dependants
        submission_date: assessment.submission_date,
      )
    end

    def partner_allowance
      Threshold.value_for(:partner_allowance, at: assessment.submission_date)
    end
  end
end

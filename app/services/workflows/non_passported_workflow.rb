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

      collate_and_assess_gross_income
      return if assessment.gross_income_summary.ineligible?

      disposable_income_assessment
      return if assessment.disposable_income_summary.ineligible?

      collate_and_assess_capital
    end

  private

    attr_reader :assessment

    # TODO: make the Collators::GrossIncomeCollator increment/sum to existing values so order of "collation" becomes unimportant
    def collate_and_assess_gross_income
      Collators::GrossIncomeCollator.call(assessment:,
                                          submission_date: assessment.submission_date,
                                          employments: assessment.employments,
                                          disposable_income_summary: assessment.disposable_income_summary,
                                          gross_income_summary: assessment.gross_income_summary)
      Collators::RegularIncomeCollator.call(assessment.gross_income_summary) # here OR call in Collators::GrossIncomeCollator
      if assessment.partner.present?
        Collators::GrossIncomeCollator.call(assessment:,
                                            submission_date: assessment.submission_date,
                                            employments: assessment.partner_employments,
                                            disposable_income_summary: assessment.partner_disposable_income_summary,
                                            gross_income_summary: assessment.partner_gross_income_summary)
        Collators::RegularIncomeCollator.call(assessment.partner_gross_income_summary)

        assessment.gross_income_summary.update!(combined_total_gross_income: assessment.gross_income_summary.total_gross_income +
                                                                            assessment.partner_gross_income_summary.total_gross_income)
      else
        assessment.gross_income_summary.update!(combined_total_gross_income: assessment.gross_income_summary.total_gross_income)
      end

      Assessors::GrossIncomeAssessor.call(
        eligibilities: assessment.gross_income_summary.eligibilities,
        total_gross_income: assessment.gross_income_summary.combined_total_gross_income,
      )
    end

    # TODO: make the Collators::DisposableIncomeCollator increment/sum to existing values so order of "collation" becomes unimportant
    def disposable_income_assessment
      if assessment.partner.present?
        applicant = PersonWrapper.new person: assessment.applicant, is_single: false,
                                      dependants: assessment.dependants, gross_income_summary: assessment.gross_income_summary
        partner = PersonWrapper.new person: assessment.partner, is_single: false,
                                    dependants: assessment.partner_dependants, gross_income_summary: assessment.partner_gross_income_summary
        eligible_for_childcare = calculate_childcare_eligibility(applicant, partner)
        Collators::OutgoingsCollator.call(submission_date: assessment.submission_date,
                                          person: applicant,
                                          gross_income_summary: assessment.gross_income_summary.freeze,
                                          disposable_income_summary: assessment.disposable_income_summary,
                                          eligible_for_childcare:,
                                          allow_negative_net: true)
        Collators::OutgoingsCollator.call(submission_date: assessment.submission_date,
                                          person: partner,
                                          gross_income_summary: assessment.partner_gross_income_summary.freeze,
                                          disposable_income_summary: assessment.partner_disposable_income_summary,
                                          eligible_for_childcare:,
                                          allow_negative_net: true)

        Collators::DisposableIncomeCollator.call(gross_income_summary: assessment.gross_income_summary.freeze,
                                                 disposable_income_summary: assessment.disposable_income_summary,
                                                 partner_allowance: 0)
        Collators::DisposableIncomeCollator.call(gross_income_summary: assessment.partner_gross_income_summary.freeze,
                                                 disposable_income_summary: assessment.partner_disposable_income_summary,
                                                 partner_allowance:)

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
      else
        applicant = PersonWrapper.new person: assessment.applicant, is_single: true,
                                      dependants: assessment.dependants, gross_income_summary: assessment.gross_income_summary
        eligible_for_childcare = calculate_childcare_eligibility(applicant)
        Collators::OutgoingsCollator.call(submission_date: assessment.submission_date,
                                          person: applicant,
                                          gross_income_summary: assessment.gross_income_summary.freeze,
                                          disposable_income_summary: assessment.disposable_income_summary,
                                          eligible_for_childcare:,
                                          allow_negative_net: false)
        Collators::DisposableIncomeCollator.call(gross_income_summary: assessment.gross_income_summary.freeze,
                                                 disposable_income_summary: assessment.disposable_income_summary,
                                                 partner_allowance: 0)
        Collators::RegularOutgoingsCollator.call(gross_income_summary: assessment.gross_income_summary.freeze,
                                                 disposable_income_summary: assessment.disposable_income_summary,
                                                 eligible_for_childcare:)
        assessment.disposable_income_summary.update!(combined_total_disposable_income: assessment.disposable_income_summary.total_disposable_income,
                                                     combined_total_outgoings_and_allowances: assessment.disposable_income_summary.total_outgoings_and_allowances)
      end
      Assessors::DisposableIncomeAssessor.call(disposable_income_summary: assessment.disposable_income_summary,
                                               total_disposable_income: assessment.disposable_income_summary.combined_total_disposable_income)
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

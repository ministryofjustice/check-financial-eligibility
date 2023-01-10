class CapitalCollatorAndAssessor
  class << self
    def call(assessment)
      data = Collators::CapitalCollator.call(
        submission_date: assessment.submission_date,
        capital_summary: assessment.capital_summary,
        maximum_subject_matter_of_dispute_disregard: maximum_subject_matter_of_dispute_disregard(assessment),
        pensioner_capital_disregard: pensioner_capital_disregard(assessment),
      )
      assessment.capital_summary.update!(data)
      if assessment.partner.present?
        partner_data = Collators::CapitalCollator.call(
          submission_date: assessment.submission_date,
          capital_summary: assessment.partner_capital_summary,
          pensioner_capital_disregard: 0,
          maximum_subject_matter_of_dispute_disregard: 0,
        )
        assessment.partner_capital_summary.update!(partner_data)
        assessment.capital_summary.update!(combined_assessed_capital: assessment.capital_summary.assessed_capital +
                                                                        assessment.partner_capital_summary.assessed_capital,
                                           combined_capital_contribution: assessment.capital_summary.capital_contribution +
                                                                            assessment.partner_capital_summary.capital_contribution)
      else
        assessment.capital_summary.update!(combined_assessed_capital: assessment.capital_summary.assessed_capital,
                                           combined_capital_contribution: assessment.capital_summary.capital_contribution)
      end
      Assessors::CapitalAssessor.call(assessment.capital_summary, assessment.capital_summary.combined_assessed_capital)
    end

  private

    def total_disposable_income(assessment)
      if assessment.partner.present?
        assessment.disposable_income_summary.total_disposable_income +
          assessment.partner_disposable_income_summary.total_disposable_income
      else
        assessment.disposable_income_summary.total_disposable_income
      end
    end

    def pensioner_capital_disregard(assessment)
      applicant_value = Calculators::PensionerCapitalDisregardCalculator.new(
        submission_date: assessment.submission_date,
        receives_qualifying_benefit: assessment.applicant.receives_qualifying_benefit,
        total_disposable_income: total_disposable_income(assessment),
        person: assessment.applicant,
      ).value
      if assessment.partner.present?
        partner_value = Calculators::PensionerCapitalDisregardCalculator.new(
          submission_date: assessment.submission_date,
          receives_qualifying_benefit: assessment.applicant.receives_qualifying_benefit,
          total_disposable_income: total_disposable_income(assessment),
          person: assessment.partner,
        ).value
      end
      [applicant_value, partner_value].compact.max
    end

    def maximum_subject_matter_of_dispute_disregard(assessment)
      Threshold.value_for(:subject_matter_of_dispute_disregard, at: assessment.submission_date)
    end
  end
end

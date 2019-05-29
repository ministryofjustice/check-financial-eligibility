class AssessmentResponseFixture < BaseAssessmentFixture
  def self.ruby_hash
    {
      assessment_id: 'e34ce98e-8cfa-4a41-a011-7a15a6724b82',
      client_reference_id: 'client-ref-1',
      result: 'eligible',
      details: {
        passported: true,
        self_employed: false,
        monthly_gross_income: 2_565.33,
        upper_income_threshold: 2_567.00,
        monthly_disposable_income: 220.55,
        disposable_income_lower_threshold: 310.00,
        disposable_income_upper_threshold: 733.00,
        liquid_capital_assessment: 45.00,
        total_capital_assessment: 2_855.55,
        total_capital_lower_threshold: 3_000.00,
        total_capital_upper_threshold: 8_000.00,
        disposable_capital_assessment: 100.00,
        monthly_contribution: 0.00,
        capital_contribution: 0.00
      },
      errors: [
        'This is error message 1',
        'This is error message 2'
      ]
    }
  end
end
# include outgoings total
# allowances  -> dependents, adult dependents, over 65, et

# return any aggregate values and any allowances, and calculated sums that we have used.

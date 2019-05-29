class AssessmentResponseFixture < BaseAssessmentFixture
  def self.ruby_hash
    {
      assessment_id: 'e34ce98e-8cfa-4a41-a011-7a15a6724b82',
      client_reference_id: 'client-ref-1',
      result: 'eligible',
      details: {
        passported: true,
        self_employed: false,
        income: {
          monthly_gross_income: 2_565.33,
          upper_income_threshold: 2_567.00,
          monthly_disposable_income: 220.55,
          disposable_income_lower_threshold: 310.00,
          disposable_income_upper_threshold: 733.00
        },
        capital: {
          liquid_capital_assessment: 45.00,
          property: {
            main_dwelling: {
              pctg_property_deduction: 3.0,
              net_value_after_deduction: 485_000.0,
              maximum_mortgage_allowance: 100_000.0,
              net_value_after_mortgage: 335_000.0,
              percentage_owned: 60.0,
              net_equity_value: 201_000.00,
              property_disregard: 100_000,
              assessed_capital_value: 101_000
            },
            additional_properties: [
              {
                pctg_property_deduction: 3.0,
                net_value_after_deduction: 485_000.0,
                maximum_mortgage_allowance: 100_000.0,
                net_value_after_mortgage: 335_000.0,
                percentage_owned: 60.0,
                net_equity_value: 201_000.00,
                property_disregard: 100_000,
                assessed_capital_value: 101_000
              },
              {
                pctg_property_deduction: 3.0,
                net_value_after_deduction: 485_000.0,
                maximum_mortgage_allowance: 100_000.0,
                net_value_after_mortgage: 335_000.0,
                percentage_owned: 60.0,
                net_equity_value: 201_000.00,
                property_disregard: 100_000,
                assessed_capital_value: 101_000
              }
            ]
          },
          total_capital_lower_threshold: 3_000.00,
          total_capital_upper_threshold: 8_000.00,
          disposable_capital_assessment: 100.00
        },
        contributions: {
          monthly_contribution: 0.00,
          capital_contribution: 0.00
        }
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

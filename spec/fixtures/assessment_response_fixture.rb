class AssessmentResponseFixture < BaseAssessmentFixture
  def self.ruby_hash
    {
      assessment_id: "e34ce98e-8cfa-4a41-a011-7a15a6724b82",
      client_reference_id: "client-ref-1",
      result: "eligible",
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
          non_liquid_capital_assessment: 3_664.0,
          property: {
            main_home: {
              notional_sale_costs_pctg: 3.0,
              net_value_after_deduction: 485_000.0,
              maximum_mortgage_allowance: 100_000.0,
              net_value_after_mortgage: 335_000.0,
              percentage_owned: 60.0,
              shared_with_housing_assoc: false,
              net_equity_value: 201_000.00,
              property_disregard: 100_000,
              assessed_capital_value: 101_000
            },
            additional_properties: [
              {
                notional_sale_costs_pctg: 3.0,
                net_value_after_deduction: 485_000.0,
                maximum_mortgage_allowance: 100_000.0,
                net_value_after_mortgage: 335_000.0,
                percentage_owned: 60.0,
                shared_with_housing_assoc: false,
                net_equity_value: 201_000.00,
                property_disregard: 100_000,
                assessed_capital_value: 101_000
              },
              {
                notional_sale_costs_pctg: 3.0,
                net_value_after_deduction: 485_000.0,
                maximum_mortgage_allowance: 100_000.0,
                net_value_after_mortgage: 335_000.0,
                percentage_owned: 60.0,
                shared_with_housing_assoc: false,
                net_equity_value: 201_000.00,
                property_disregard: 100_000,
                assessed_capital_value: 101_000
              }
            ]
          },
          vehicles: [
            {
              value: 12_500,
              loan_amount_outstanding: 7_200,
              date_of_purchase: 34.months.ago.to_date,
              in_regular_use: true,
              assessed_value: 5_300
            },
            {
              value: 4_300,
              loan_amount_outstanding: 0,
              date_of_purchase: 40.months.ago.to_date,
              in_regular_use: true,
              assessed_value: 0
            }
          ],
          single_capital_assessment: 75_000.0,
          pensioner_disregard: 100_000.0,
          disposable_capital_assessment: 25_000.0,
          total_capital_lower_threshold: 3_000.0,
          total_capital_upper_threshold: 8_000.0
        },
        contributions: {
          monthly_contribution: 0.00,
          capital_contribution: 0.00
        }
      },
      errors: [
        "This is error message 1",
        "This is error message 2"
      ]
    }
  end
end
# include outgoings total
# allowances  -> dependants, adult dependants, over 65, et

# return any aggregate values and any allowances, and calculated sums that we have used.

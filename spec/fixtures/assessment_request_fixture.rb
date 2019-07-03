class AssessmentRequestFixture < BaseAssessmentFixture # rubocop:disable Metrics/ClassLength
  def self.ruby_hash # rubocop:disable Metrics/MethodLength
    {
      client_reference_id: 'my-eligibility-check-01',
      meta_data: {
        submission_date: Date.parse('02 Apr 2019'),
        matter_proceeding_type: 'domestic_abuse'
      },
      applicant: {
        date_of_birth: Date.parse('13 Aug 1953'),
        involvement_type: 'applicant',
        has_partner_opponent: false,
        receives_qualifying_benefit: false,
        dependants: [
          {
            date_of_birth: Date.parse('02 Feb 1995'),
            in_full_time_education: false,
            income: [
              {
                date_of_payment: Date.parse('20 Feb 2019'),
                amount: 40.34
              },
              {
                date_of_payment: Date.parse('20 Mar 2019'),
                amount: 40.35
              }
            ]
          },
          {
            date_of_birth: Date.parse('04 Mar 1997'),
            in_full_time_education: true
          }
        ]
      },
      applicant_income: {
        wage_slips: [
          {
            date: Date.parse('30 Jan 2019'),
            gross_pay: 12_345.22,
            paye: 456.79,
            national_insurance_contribution: 45.67
          },
          {
            date: Date.parse('27 Feb 2019'),
            gross_pay: 12_345.22,
            paye: 456.79,
            national_insurance_contribution: 45.67
          }
        ],
        benefits: [
          {
            benefit_name: 'child_allowance',
            payment_date: Date.parse('15 Jan 2019'),
            amount: 200.66
          },
          {
            benefit_name: 'jobseekers_allowance',
            payment_date: Date.parse('15 Jan 2019'),
            amount: 100.44
          }
        ]
      },
      applicant_outgoings: [
        {
          outgoing_type: 'mortgage',
          payment_date: Date.parse('22 Jan 2019'),
          amount: 356.77
        },
        {
          outgoing_type: 'maintenance',
          payment_date: Date.parse('22 Jan 2019'),
          amount: 166.98
        }
      ],
      applicant_capital: {
        property: {
          main_home: {
            value: 466_933,
            outstanding_mortgage: 266_000,
            percentage_owned: 50,
            shared_with_housing_assoc: false
          },
          additional_properties: [
            {
              value: 466_933,
              outstanding_mortgage: 266_000,
              percentage_owned: 100,
              shared_with_housing_assoc: false
            },
            {
              value: 466_933,
              outstanding_mortgage: 266_000,
              percentage_owned: 33.33,
              shared_with_housing_assoc: false
            }
          ]
        },
        vehicles: [
          {
            value: 9500,
            loan_amount_outstanding: 6000,
            date_of_purchase: Date.parse('13 Aug 2015'),
            in_regular_use: true
          }
        ],
        liquid_capital: {
          bank_accounts: [
            {
              account_name: 'Account #1',
              lowest_balance: -33.44
            },
            {
              account_name: 'Account #2',
              lowest_balance: 256.44
            }
          ]
        },
        non_liquid_capital: [
          {
            item_description: 'stocks and shares',
            value: 34_000
          },
          {
            item_description: 'trust fund',
            value: 34_000
          },
          {
            item_description: 'jewllery',
            value: 2_225
          }
        ]
      }
    }
  end
end

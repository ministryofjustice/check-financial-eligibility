class AssessmentFixture
  def self.ruby_hash
    {
      client_reference_id: 'my-eligibility-check-01',
      meta_data: {
        submission_date: Date.parse('02 Apr 2019'),
        matter_proceeding_type: 'Domestic abuse'
      },
      applicant: {
        date_of_birth: Date.parse('13 Aug 1953'),
        involvement_type: 'applicant',
        has_partner_opponent: false,
        receives_qualifying_benefit: false,
        dependents: [
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
                amount: 40.34
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
          type_of_outgoing: 'mortgage',
          payment_date: Date.parse('22 Jan 2019'),
          amount: 356.77
        },
        {
          type_of_outgoing: 'maintenance',
          payment_date: Date.parse('22 Jan 2019'),
          amount: 166.98
        }
      ],
      applicant_capital: {
        property: {
          main_home: {
            value: 466_933,
            outstanding_mortgage: 266_000,
            percentage_owned: 50
          },
          other_properties: [
            {
              value: 466_933,
              outstanding_mortgage: 266_000,
              percentage_owned: 100
            },
            {
              value: 466_933,
              outstanding_mortgage: 266_000,
              percentage_owned: 33.33
            }
          ]
        },
        liquid_capital: {
          valuable_items: [
            {
              item_description: 'jewellery',
              value: 34_000
            }
          ],
          vehicles: [
            {
              value: 9500,
              loan_amount_outstanding: 6000
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
          }
        ]
      }
    }
  end
end

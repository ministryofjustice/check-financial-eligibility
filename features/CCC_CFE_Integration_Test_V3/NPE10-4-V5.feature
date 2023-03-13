Feature:
  ""NON-PASSPORT TEST - CONCERN4 - CHILDCARE ALLOWED
  1) Post 6th April dependant Rates
  2) Client has education income and dependnat under 15""

  Scenario: Test that the correct output is produced for the following set of data.
    Given I am using version 5 of the API
    And I create an assessment with the following details:
      | submission_date     | 2020-04-21 |
    And I add the following applicant details for the current assessment:
      | date_of_birth               | 1972-12-20 |
      | involvement_type            | applicant  |
      | has_partner_opponent        | false      |
      | receives_qualifying_benefit | false      |
    And I add the following proceeding types in the current assessment:
      | ccms_code | client_involvement_type |
      | DA001     | A                       |
    And I add the following dependent details for the current assessment:
      | date_of_birth | in_full_time_education | relationship   | monthly_income | assets_value |
      | 2008-12-20    | TRUE                   | child_relative | 0.00           | 0.00         |
    And I add the following irregular_income details in the current assessment:
      | income_type  | frequency | amount  |
      | student_loan | annual    | 1200.00 |
    And I add the following outgoing details for "child_care" in the current assessment:
      | payment_date | client_id | amount |
      | 2020-02-29   | og-id1    | 200.00 |
      | 2020-03-27   | og-id2    | 200.00 |
      | 2020-04-26   | og-id3    | 200.00 |
    And I add the following capital details for "bank_accounts" in the current assessment:
      | description | value  |
      | Bank acc 1  | 3002.0 |
    When I retrieve the final assessment

    Then I should see the following overall summary:
      | attribute                    | value                 |
      | assessment_result            | contribution_required |
      | capital_lower_threshold      | 3000.0                |
    And I should see the following "disposable_income_summary" details:
      | attribute                      | value    |
      | dependant_allowance            |  296.65  |
      | total_outgoings_and_allowances |  496.65  |
      | total_disposable_income        | -396.65  |


Feature:
    "1. Fully eligible, 2. No contribution"

    Scenario: Test that the correct output is produced for the following set of data.
        Given I am using version 5 of the API
        And I create an assessment with the following details:
            | client_reference_id | NP-FULL-2  |
            | submission_date     | 2021-05-10 |
        And I add the following applicant details for the current assessment:
            | date_of_birth               | 1979-12-20 |
            | involvement_type            | applicant  |
            | has_partner_opponent        | false      |
            | receives_qualifying_benefit | false      |
        And I add the following proceeding types in the current assessment:
            | ccms_code | client_involvement_type |
            | DA001     | A                       |
            | SE013     | A                       |
            | SE003     | A                       |
        And I add the following dependent details for the current assessment:
            | date_of_birth | in_full_time_education | relationship   | monthly_income | assets_value |
            | 2018-12-20    | FALSE                  | child_relative | 0.00           | 0.00         |
        And I add the following other_income details for "friends_or_family" in the current assessment:
            | date       | client_id | amount |
            | 2021-05-10 | id1       | 100.00 |
            | 2021-04-10 | id2       | 100.00 |
            | 2021-03-10 | id3       | 100.00 |
        And I add the following irregular_income details in the current assessment:
            | income_type  | frequency | amount |
            | student_loan | annual    | 120.00 |
        And I add the following outgoing details for "rent_or_mortgage" in the current assessment:
            | payment_date | housing_cost_type | client_id | amount |
            | 2021-05-10   | rent              | id7       | 10.00  |
            | 2021-04-10   | rent              | id8       | 10.00  |
            | 2021-03-10   | rent              | id9       | 10.00  |
        And I add the following capital details for "bank_accounts" in the current assessment:
            | description | value  |
            | Bank acc 1  | 2999.0 |
            | Bank acc 2  | 0      |
            | Bank acc 3  | 0      |
        When I retrieve the final assessment

        Then I should see the following overall summary:
            | attribute                    | value    |
            | assessment_result            | eligible |
            | capital_lower_threshold      | 3000.0   |
            | gross_income_upper_threshold | 2657.0   |

        Then I should see the following "gross_income_proceeding_types" details where "ccms_code:SE013":
            | attribute               | value    |
            | client_involvement_type | A        |
            | upper_threshold         | 2657.0   |
            | lower_threshold         | 0.0      |
            | result                  | eligible |

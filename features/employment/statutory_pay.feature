Feature:
    "Statutory pay"

    Scenario: The client is receiving statutory sick pay only
        Given I am using version 5 of the API
        And I create an assessment with the following details:
            | client_reference_id | NP-FULL-1  |
            | submission_date     | 2023-01-10 |
        And I add the following applicant details for the current assessment:
            | date_of_birth               | 1979-12-20 |
            | involvement_type            | applicant  |
            | has_partner_opponent        | false      |
            | receives_qualifying_benefit | false      |
        And I add the following proceeding types in the current assessment:
            | ccms_code | client_involvement_type |
            | SE013     | A                       |
        And I add the following statutory sick pay details for the client:
            | client_id |     date     |  gross | benefits_in_kind  | tax   | national_insurance | net_employment_income  |
            |     C     |  2022-07-22  | 500.50 |       0           | 0.00 |       0.0           |        500.50          |
            |     C     |  2022-08-22  | 500.50 |       0           | 0.00 |       0.0           |        500.50          |
            |     C     |  2022-09-22  | 500.50 |       0           | 0.00 |       0.0           |        500.50          |
        When I retrieve the final assessment
        Then I should see the following "employment" details:
            | attribute                  | value    |
            | fixed_employment_deduction | 0.0      |

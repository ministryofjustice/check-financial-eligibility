Feature:
    "I have income from unspecified sources to declare in my assessment"

    Scenario: Test that the correct output is produced for the following set of data.
        Given I am using version 5 of the API
        And I create an assessment with the following details:
            | submission_date     | 2022-05-10 |
        And I add the following applicant details for the current assessment:
            | date_of_birth               | 1979-12-20 |
            | involvement_type            | applicant  |
            | has_partner_opponent        | false      |
            | receives_qualifying_benefit | false      |
        And I add the following proceeding types in the current assessment:
            | ccms_code | client_involvement_type |
            | DA001     | A                       |
        And I add the following irregular_income details in the current assessment:
            | income_type               | frequency    | amount |
            | unspecified_source        | quarterly    | 336.33 |
        When I retrieve the final assessment
        Then I should see the following "disposable_income_summary" details:
            | attribute               | value    |
            | total_disposable_income | 112.11   |

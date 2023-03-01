Feature:
    "Asylum Support"

    Scenario: Asylum supported users receive eligible result without further details needed
        Given I am using version 5 of the API
        And I create an assessment with the following details:
            | client_reference_id | NP-FULL-1  |
            | submission_date     | 2023-01-10 |
        And I add the following applicant details for the current assessment:
            | date_of_birth               | 1979-12-20 |
            | involvement_type            | applicant  |
            | has_partner_opponent        | false      |
            | receives_qualifying_benefit | false      |
            | receives_asylum_support     | true       |
        And I add the following proceeding types in the current assessment:
            | ccms_code | client_involvement_type |
            | IM030     | A                       |
        When I retrieve the final assessment

        Then I should see the following overall summary:
            | attribute                    | value    |
            | assessment_result            | eligible |

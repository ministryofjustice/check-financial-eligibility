Feature:
    "I have a vehicle that is disputed"

    Scenario: A SMOD vehicle whose assessed value is entirely disregarded
      Given I am undertaking a certificated assessment
      And An applicant who receives passporting benefits
        And I am using version 5 of the API
        And I add the following vehicle details for the current assessment:
            | value                     | 18000      |
            | loan_amount_outstanding   | 0          |
            | date_of_purchase          | 2018-11-23 |
            | in_regular_use            | false      |
            | subject_matter_of_dispute | true       |
        When I retrieve the final assessment
        Then I should see the following "vehicle" details:
            | attribute       | value   |
            | value           | 18000.0 |
            | assessed_value  | 18000.0 |
        And I should see the following "capital summary" details:
            | attribute                           | value   |
            | total_vehicle                       | 18000.0 |
            | subject_matter_of_dispute_disregard | 18000.0 |
            | assessed_capital                    | 0.0     |

    Scenario: A SMOD vehicle whose assessed value is over the SMOD limit
      Given I am undertaking a certificated assessment
      And An applicant who receives passporting benefits
        And I am using version 5 of the API
        And I add the following vehicle details for the current assessment:
            | value                     | 180000     |
            | loan_amount_outstanding   | 0          |
            | date_of_purchase          | 2018-11-23 |
            | in_regular_use            | false      |
            | subject_matter_of_dispute | true       |
        When I retrieve the final assessment
        Then I should see the following "vehicle" details:
            | attribute       | value   |
            | value           | 180000.0 |
            | assessed_value  | 180000.0 |
        And I should see the following "capital summary" details:
            | attribute                           | value    |
            | total_vehicle                       | 180000.0 |
            | subject_matter_of_dispute_disregard | 100000.0 |
            | assessed_capital                    | 80000.0  |

    Scenario: A SMOD vehicle whose assessed value is partially disregarded due to other SMOD assets reaching SMOD cap
      Given I am undertaking a certificated assessment
      And An applicant who receives passporting benefits
        And I am using version 5 of the API
        And I add the following vehicle details for the current assessment:
            | value                     | 18000      |
            | loan_amount_outstanding   | 0          |
            | date_of_purchase          | 2018-11-23 |
            | in_regular_use            | false      |
            | subject_matter_of_dispute | true       |
        And I add the following main property details for the current assessment:
            | value                     | 200000 |
            | outstanding_mortgage      | 0      |
            | percentage_owned          | 100    |
            | shared_with_housing_assoc | false  |
            | subject_matter_of_dispute | true   |
        When I retrieve the final assessment
        Then I should see the following "main property" details:
            | attribute                  | value    |
            | value                      | 200000.0 |
            | net_equity                 | 194000.0 |
            | smod_allowance             | 100000.0 |
            | main_home_equity_disregard |  94000.0 |
            | transaction_allowance      | 6000.0   |
            | assessed_equity            | 0.0      |
        And I should see the following "vehicle" details:
            | attribute       | value   |
            | value           | 18000.0 |
            | assessed_value  | 18000.0 |
        And I should see the following "capital summary" details:
            | attribute                           | value    |
            | total_property                      | 0.0      |
            | total_vehicle                       | 18000.0  |
            | subject_matter_of_dispute_disregard | 100000.0 |
            | assessed_capital                    | 18000.0  |

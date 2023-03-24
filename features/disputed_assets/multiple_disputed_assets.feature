Feature:
  "I have multiple disputed assets"

  Scenario: A client with disputed property and vehicle
    Given I am undertaking a certificated assessment
    And An applicant who receives passporting benefits
    And I am using version 5 of the API
    And I add the following main property details for the current assessment:
      | value                     | 150000 |
      | outstanding_mortgage      | 100000 |
      | percentage_owned          | 100    |
      | shared_with_housing_assoc | false  |
      | subject_matter_of_dispute | true   |
    And I add the following vehicle details for the current assessment:
      | value                     | 18000      |
      | loan_amount_outstanding   | 0          |
      | date_of_purchase          | 2018-11-23 |
      | in_regular_use            | false      |
      | subject_matter_of_dispute | true       |
    And I add the following capital details for "bank_accounts" in the current assessment:
      | description  | value   | subject_matter_of_dispute |
      | Bank account | 5000.0  | true                      |
    When I retrieve the final assessment
    Then I should see the following "main property" details:
      | attribute                  | value    |
      | value                      | 150000.0 |
      | net_equity                 |  45500.0 |
      | smod_allowance             |  45500.0 |
      | main_home_equity_disregard |      0.0 |
      | transaction_allowance      | 4500.0   |
      | assessed_equity            | 0.0      |
    And I should see the following "capital summary" details:
      | attribute                           | value   |
      | total_property                      | 0.0     |
      | subject_matter_of_dispute_disregard | 68500.0 |
      | disputed_non_property_disregard     | 23000.0 |
      | assessed_capital                    | 0.0     |

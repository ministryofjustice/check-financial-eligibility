Feature:
    "I have a property that is disputed"

    Scenario: A SMOD property where the value of the client's share of its equity is entirely disregarded
        Given I am undertaking a certificated assessment with an applicant who receives passporting benefits
        And I am using version 5 of the API
        And I add the following main property details for the current assessment:
            | value                     | 150000 |
            | outstanding_mortgage      | 0      |
            | percentage_owned          | 100    |
            | shared_with_housing_assoc | false  |
            | subject_matter_of_dispute | true   |
        When I retrieve the final assessment
        Then I should see the following "main property" details:
            | attribute                  | value    |
            | value                      | 150000.0 |
            | main_home_equity_disregard | 100000.0 |
            | transaction_allowance      | 4500.0   |
            | assessed_equity            | 0.0      |
        And I should see the following "capital summary" details:
            | attribute                           | value    |
            | total_property                      | 0.0      |
            | subject_matter_of_dispute_disregard | 100000.0 |
            | assessed_capital                    | 0.0      |

    Scenario: The SMOD disregard is capped if the property is assessed as being worth more than £100k.
        Given I am undertaking a certificated assessment with an applicant who receives passporting benefits
        And I am using version 5 of the API
        And I add the following main property details for the current assessment:
            | value                     | 250000 |
            | outstanding_mortgage      | 0      |
            | percentage_owned          | 100    |
            | shared_with_housing_assoc | false  |
            | subject_matter_of_dispute | true   |
        When I retrieve the final assessment
        Then I should see the following "main property" details:
            | attribute                  | value    |
            | value                      | 250000.0 |
            | main_home_equity_disregard | 100000.0 |
            | transaction_allowance      | 7500.0   |
            | assessed_equity            | 42500.0  |
        And I should see the following "capital summary" details:
            | attribute                           | value    |
            | total_property                      | 42500.0  |
            | subject_matter_of_dispute_disregard | 100000.0 |
            | assessed_capital                    | 42500.0  |

    Scenario: Disputed main and additional properties which, combined, are assessed as worth less than £100k
        Given I am undertaking a certificated assessment with an applicant who receives passporting benefits
        And I am using version 5 of the API
        And I add the following main property details for the current assessment:
            | value                     | 250000 |
            | outstanding_mortgage      | 0      |
            | percentage_owned          | 50     |
            | shared_with_housing_assoc | false  |
            | subject_matter_of_dispute | true   |
        And I add the following additional property details for the current assessment:
            | value                     | 50000 |
            | outstanding_mortgage      | 0      |
            | percentage_owned          | 100    |
            | shared_with_housing_assoc | false  |
            | subject_matter_of_dispute | true   |
        When I retrieve the final assessment
        Then I should see the following "main property" details:
            | attribute                  | value    |
            | value                      | 250000.0 |
            | main_home_equity_disregard | 100000.0 |
            | transaction_allowance      | 7500.0   |
            | assessed_equity            | 0.0      |
        Then I should see the following "additional property" details:
            | attribute                  | value   |
            | value                      | 50000.0 |
            | main_home_equity_disregard | 0.0     |
            | transaction_allowance      | 1500.0  |
            | assessed_equity            | 48500.0 |
        And I should see the following "capital summary" details:
            | attribute                           | value    |
            | total_property                      | 48500.0  |
            | subject_matter_of_dispute_disregard | 100000.0 |
            | assessed_capital                    | 48500.0  |

  Scenario: Disputed main and additional property under 100k with controlled work
    Given I am undertaking a controlled work assessment with an applicant who receives passporting benefits
    And I am using version 5 of the API
    And I add the following main property details for the current assessment:
      | value                     | 300000 |
      | outstanding_mortgage      | 80000  |
      | percentage_owned          | 50     |
      | shared_with_housing_assoc | false  |
      | subject_matter_of_dispute | true   |
    And I add the following additional property details for the current assessment:
      | value                     | 90000  |
      | outstanding_mortgage      | 80000  |
      | percentage_owned          | 50     |
      | shared_with_housing_assoc | false  |
      | subject_matter_of_dispute | true   |
    When I retrieve the final assessment
    Then I should see the following "main property" details:
      | attribute                  | value    |
      | value                      | 300000.0 |
      | net_value                  | 220000.0 |
      | net_equity                 | 110000.0 |
      | main_home_equity_disregard | 100000.0 |
      | assessed_equity            | 0.0      |
    And I should see the following "additional property" details:
      | attribute                  | value   |
      | value                      | 90000.0 |
      | net_value                  | 10000.0 |
      | net_equity                 | 5000.0  |
      | assessed_equity            | 5000.0  |
    And I should see the following "capital summary" details:
      | attribute                            | value    |
      | subject_matter_of_dispute_disregard  | 100000.0 |
      | assessed_capital                     | 5000.0   |

  Scenario: Disputed main and additional property where main equity > 100k and < 200k
    Given I am undertaking a certificated assessment with an applicant who receives passporting benefits
    And I am using version 5 of the API
    And I add the following main property details for the current assessment:
      | value                     | 400000 |
      | outstanding_mortgage      | 0      |
      | percentage_owned          | 50     |
      | shared_with_housing_assoc | false  |
      | subject_matter_of_dispute | true   |
    And I add the following additional property details for the current assessment:
      | value                     | 60000  |
      | outstanding_mortgage      | 40000  |
      | percentage_owned          | 50     |
      | shared_with_housing_assoc | false  |
      | subject_matter_of_dispute | true   |
    When I retrieve the final assessment
    Then I should see the following "main property" details:
      | attribute                  | value    |
      | value                      | 400000.0 |
      | transaction_allowance      | 12000.0  |
      | net_value                  | 388000.0 |
      | net_equity                 | 194000.0 |
      | main_home_equity_disregard | 100000.0 |
      | assessed_equity            | 0.0      |
    And I should see the following "additional property" details:
      | attribute                  | value   |
      | value                      | 60000.0 |
      | transaction_allowance      | 1800.0  |
      | net_value                  | 18200.0 |
      | net_equity                 | 9100.0  |
      | assessed_equity            | 9100.0  |
    And I should see the following "capital summary" details:
      | attribute                            | value    |
      | subject_matter_of_dispute_disregard  | 100000.0 |
      | assessed_capital                     | 9100.0   |

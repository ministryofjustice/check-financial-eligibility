Feature:
    "I have a disputed capital items"

    Scenario: A SMOD bank account whose value is entirely disregarded
      Given I am undertaking a certificated assessment
      And An applicant who receives passporting benefits
        And I am using version 5 of the API
        And I add the following capital details for "bank_accounts" in the current assessment:
            | description  | value   | subject_matter_of_dispute |
            | Bank account | 5000.0  | true                      |
        When I retrieve the final assessment
        Then I should see the following "capital summary" details:
            | attribute                           | value  |
            | total_liquid                        | 5000.0 |
            | subject_matter_of_dispute_disregard | 5000.0 |
            | assessed_capital                    | 0.0    |

    Scenario: A SMOD investment whose value is entirely disregarded
      Given I am undertaking a certificated assessment
      And An applicant who receives passporting benefits
        And I am using version 5 of the API
        And I add the following capital details for "non_liquid_capital" in the current assessment:
            | description    | value   | subject_matter_of_dispute |
            | Investment     | 50000.0 | true                      |
            | Valuable item  | 25000.0 | false                     |
        When I retrieve the final assessment
        Then I should see the following "capital summary" details:
            | attribute                           | value   |
            | total_non_liquid                    | 75000.0 |
            | subject_matter_of_dispute_disregard | 50000.0 |
            | assessed_capital                    | 25000.0 |

    Scenario: A SMOD bank account whose value is over the SMOD disregard limit
      Given I am undertaking a certificated assessment
      And An applicant who receives passporting benefits
        And I am using version 5 of the API
        And I add the following capital details for "bank_accounts" in the current assessment:
            | description | value    | subject_matter_of_dispute |
            | Bank acc 1  | 150000.0 | true                      |
        When I retrieve the final assessment
        Then I should see the following "capital summary" details:
            | attribute                           | value    |
            | total_liquid                        | 150000.0 |
            | subject_matter_of_dispute_disregard | 100000.0 |
            | assessed_capital                    | 50000.0  |

    Scenario: Two SMOD assets whose combined value is over the SMOD disregard limit
      Given I am undertaking a certificated assessment
      And An applicant who receives passporting benefits
        And I am using version 5 of the API
        And I add the following capital details for "bank_accounts" in the current assessment:
            | description | value   | subject_matter_of_dispute |
            | Bank acc 1  | 50000.0 | true                      |
        And I add the following capital details for "non_liquid_capital" in the current assessment:
            | description    | value   | subject_matter_of_dispute |
            | Investment     | 60000.0 | true                      |
        When I retrieve the final assessment
        Then I should see the following "capital summary" details:
            | attribute                           | value    |
            | total_liquid                        | 50000.0  |
            | total_non_liquid                    | 60000.0  |
            | subject_matter_of_dispute_disregard | 100000.0 |
            | assessed_capital                    | 10000.0  |

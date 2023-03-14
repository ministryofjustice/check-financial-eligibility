Feature:
  "I have multiple disputed assets"

  Scenario: A pensioner with disputed savings, property and vehicle
    Given I am undertaking a certificated assessment with a pensioner applicant who is not passported
    And I am using version 5 of the API
    And I add the following employment details:
      | client_id |     date     |  gross | benefits_in_kind  | tax   | national_insurance |
      |     C     |  2022-07-22  | 200.50 |       0           | 75.00 |       15.0         |
      |     C     |  2022-08-22  | 200.50 |       0           | 75.00 |       15.0         |
      |     C     |  2022-09-22  | 200.50 |       0           | 75.00 |       15.0         |
    And I add the following capital details for "bank_accounts" in the current assessment:
      | description  | value   | subject_matter_of_dispute |
      | Bank account | 91000.0 | true                      |
    And I add the following capital details for "non_liquid_capital" in the current assessment:
      | description  | value   | subject_matter_of_dispute |
      | Jewelry      | 12000.0 | true                      |
    When I retrieve the final assessment
    Then I should see the following "capital summary" details:
      | attribute                           | value    |
      | total_property                      |      0.0 |
      | subject_matter_of_dispute_disregard | 100000.0 |
      | disputed_non_property_disregard     | 100000.0 |
      | pensioner_capital_disregard         |  10000.0 |
      | pensioner_disregard_applied         |   3000.0 |
      | assessed_capital                    |      0.0 |

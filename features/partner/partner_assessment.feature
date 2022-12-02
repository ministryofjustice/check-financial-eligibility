Feature:
  "Applicant have a partner"

  Scenario: An applicant with a partner who has capital
    Given I am undertaking a standard assessment with an applicant who receives passporting benefits
#    And I add the following partner details to the current assessment:
#      | date_of_birth               | 1984-08-28 |
#      | employed                    | false      |
    And I add the following irregular_income details for the partner in the current assessment:
      | income_type               | frequency    | amount  |
      | student_loan              | annual       | 9999.99 |
      | unspecified_source        | quarterly    | 336.33  |
#    And I add the following vehicle details for the partner in the current assessment:
#      | value                       | 5000       |
#      | loan_amount_outstanding     | 1000       |
#      | date_of_purchase            | 2017-01-23 |
#      | in_regular_use              | true       |
#      | subject_matter_of_dispute   | false      |
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
      | assessed_equity            | 45500.0  |
    And I should see the following "capital summary" details:
      | attribute                           | value   |
      | total_property                      | 45500.0 |
      | subject_matter_of_dispute_disregard | 45500.0 |
      | assessed_capital                    | 0.0     |
#    And I should see the following "irregular_income" details for the partner:
#      | attribute                           | value   |
#      | total_property                      | 45500.0 |
#      | subject_matter_of_dispute_disregard | 45500.0 |
#      | assessed_capital                    | 0.0     |

  Scenario: The SMOD disregard is capped if the property is assessed as being worth more than £100k.
    Given I am undertaking a standard assessment with an applicant who receives passporting benefits
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
      | assessed_equity            | 142500.0 |
    And I should see the following "capital summary" details:
      | attribute                           | value    |
      | total_property                      | 142500.0 |
      | subject_matter_of_dispute_disregard | 100000.0 |
      | assessed_capital                    | 42500.0  |

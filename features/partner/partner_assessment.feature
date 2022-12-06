Feature:
  "Applicant have a partner"

  Scenario: An applicant with a partner who has irregular_income
    Given I am undertaking a standard assessment with an applicant who receives passporting benefits
#    And I add the following partner details to the current assessment:
#      | date_of_birth               | 1984-08-28 |
#      | employed                    | false      |
#    And I add the following irregular_income details for the partner in the current assessment:
#      | income_type               | frequency    | amount  |
#      | student_loan              | annual       | 9999.99 |
#      | unspecified_source        | quarterly    | 336.33  |
    And I add the following capital details for the partner in the current assessment:
      | income_type               | frequency    | amount  |
      | student_loan              | annual       | 9999.99 |
      | unspecified_source        | quarterly    | 336.33  |
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
#    And I should see the following "partner irregular income" details for the partner:
#      | attribute                           | value   |
#      | student_loan                        | 123.0   |
#      | unspecified_source                  | 100.0   |
    And I should see the following "partner_capital" details for the partner:
      | attribute                  | value     |
      | value                      | 235000.01 |
      | outstanding_mortgage       | 14999.99  |
      | percentage_owned           | 50.0      |
      | shared_with_housing_assoc  | false     |

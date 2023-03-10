Feature:
  "Applicant has a partner"

  Scenario: An applicant with a partner who has additional property (capital)
    Given I am undertaking a certificated assessment with an applicant who receives passporting benefits
    And I am using version 5 of the API
    And I add the following main property details for the current assessment:
      | value                     | 150000 |
      | outstanding_mortgage      | 145000 |
      | percentage_owned          | 100    |
      | shared_with_housing_assoc | false  |
      | subject_matter_of_dispute | true   |
    And I add the following additional property details for the partner in the current assessment:
      | value                       | 170000.00 |
      | outstanding_mortgage        | 100000.00 |
      | percentage_owned            | 100       |
      | shared_with_housing_assoc   | false     |
      | subject_matter_of_dispute   | false     |
    When I retrieve the final assessment
    Then I should see the following "main property" details:
      | attribute                  | value    |
      | value                      | 150000.0 |
      | main_home_equity_disregard | 100000.0 |
      | transaction_allowance      | 4500.0   |
      | assessed_equity            | 0.0      |
    And I should see the following "partner_capital" details for the partner:
      | attribute                  | value     |
      | value                      | 170000.0  |
      | outstanding_mortgage       | 100000.0  |
      | percentage_owned           | 100.0     |
      | shared_with_housing_assoc  | false     |
      | assessed_equity            | 64900.0   |
      | net_value                  | 64900.0   |
    And I should see the following overall summary:
      | attribute                    | value                 |
      | assessment_result            | contribution_required |

Scenario: An applicant and partner's combined capital is over the lower threshold
  Given I am undertaking a certificated assessment with an applicant who receives passporting benefits
    And I am using version 5 of the API
    And I add the following capital details for "bank_accounts" in the current assessment:
      | description  | value   | subject_matter_of_dispute |
      | Bank account | 2000.0  | false                     |
    And I add the following capital details for "bank_accounts" for the partner:
      | description  | value   |
      | Bank account | 2000.0  |
    When I retrieve the final assessment
    And I should see the following overall summary:
      | attribute                    | value                 |
      | assessment_result            | contribution_required |
      | capital contribution         | 1000.0                |

  Scenario: An unemployed applicant with an employed partner
    Given I am undertaking a certificated assessment with a pensioner applicant who is not passported
    And I am using version 5 of the API
    And I add the following employment details for the partner:
      | client_id |     date     |  gross | benefits_in_kind  | tax   | national_insurance | net_employment_income |
      |     C     |  2022-07-22  | 500.50 |       0           | 75.00 |       15.0         |        410.5          |
      |     C     |  2022-08-22  | 500.50 |       0           | 75.00 |       15.0         |        410.5          |
      |     C     |  2022-09-22  | 500.50 |       0           | 75.00 |       15.0         |        410.5          |
    When I retrieve the final assessment
    Then I should see the following "overall_disposable_income" details:
      | attribute                    | value    |
      | total_disposable_income      | 354.09   |
    And I should see the following overall summary:
      | attribute                  | value                 |
      | assessment_result          | contribution_required |
      | income contribution        | 15.08                 |
      | capital contribution       | 0.0                   |

  Scenario: A applicant with a partner with capital and both pensioners
    Given I am undertaking a certificated assessment with a pensioner applicant who is not passported
    And I am using version 5 of the API
    And I add the following employment details for the partner:
      | client_id |     date     |  gross | benefits_in_kind  | tax   | national_insurance | net_employment_income |
      |     C     |  2022-07-22  | 500.50 |       0           | 75.00 |       15.0         |        410.5          |
      |     C     |  2022-08-22  | 500.50 |       0           | 75.00 |       15.0         |        410.5          |
      |     C     |  2022-09-22  | 500.50 |       0           | 75.00 |       15.0         |        410.5          |
    And I add the following additional property details for the partner in the current assessment:
      | value                       | 170000.00 |
      | outstanding_mortgage        | 100000.00 |
      | percentage_owned            | 100       |
      | shared_with_housing_assoc   | false     |
      | subject_matter_of_dispute   | false     |
    When I retrieve the final assessment
    And I should see the following overall summary:
      | attribute                  | value                 |
      | assessment_result          | ineligible            |
      | income contribution        | 15.08                 |
      | capital contribution       | 61900.0               |

  Scenario: A applicant with housing benefit and a partner with housing costs
    Given I am undertaking a certificated assessment with a pensioner applicant who is not passported
    And I am using version 5 of the API
    And I add the following housing benefit details for the applicant:
      | client_id |     date     |  amount |
      |     C     |  2022-07-22  | 500.0   |
      |     C     |  2022-08-22  | 500.0   |
      |     C     |  2022-09-22  | 500.0   |
    And I add the following regular_transaction details for the partner:
      | operation | category         | frequency | amount |
      | debit     | rent_or_mortgage | monthly   | 600.0  |
    When I retrieve the final assessment
    And I should see the following overall summary:
      | attribute                      | value    |
      | partner allowance              | 191.41   |
      | total outgoings and allowances | 291.41   |

  Scenario: An applicant with an employed partner who is over the gross income threshold
    Given I am undertaking a certificated assessment with a pensioner applicant who is not passported
    And I am using version 5 of the API
    And I add the following employment details for the partner:
      | client_id |     date     |  gross | benefits_in_kind  | tax   | national_insurance | net_employment_income |
      |     C     |  2022-07-22  | 5000.50 |       0           | 75.00 |       15.0         |        410.5          |
      |     C     |  2022-08-22  | 5000.50 |       0           | 75.00 |       15.0         |        410.5          |
      |     C     |  2022-09-22  | 5000.50 |       0           | 75.00 |       15.0         |        410.5          |
    When I retrieve the final assessment
    Then I should see the following overall summary:
      | attribute                  | value                 |
      | assessment_result          | ineligible            |


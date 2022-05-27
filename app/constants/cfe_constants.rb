module CFEConstants
  # Versions
  #
  DEFAULT_ASSESSMENT_VERSION = "4".freeze
  VALID_ASSESSMENT_VERSIONS = [DEFAULT_ASSESSMENT_VERSION, "3"].freeze

  # Income categories
  #
  VALID_INCOME_CATEGORIES = %w[benefits friends_or_family maintenance_in property_or_lodger pension].freeze
  HUMANIZED_INCOME_CATEGORIES = (VALID_INCOME_CATEGORIES + VALID_INCOME_CATEGORIES.map(&:humanize)).freeze

  # Outgoings categories
  #
  OUTGOING_KLASSES = {
    child_care: Outgoings::Childcare,
    rent_or_mortgage: Outgoings::HousingCost,
    maintenance_out: Outgoings::Maintenance,
    legal_aid: Outgoings::LegalAid,
  }.freeze
  VALID_OUTGOING_CATEGORIES = OUTGOING_KLASSES.keys.map(&:to_s).freeze
  VALID_OUTGOING_HOUSING_COST_TYPES = %w[rent mortgage board_and_lodging].freeze

  # Remark categories
  #
  VALID_REMARK_CATEGORIES = %w[policy_disregards].freeze
  VALID_REMARK_TYPES = %i[
    other_income_payment
    state_benefit_payment
    outgoings_child_care
    outgoings_childcare
    outgoings_legal_aid
    outgoings_maintenance
    outgoings_maintenance_out
    outgoings_housing_cost
    outgoings_rent_or_mortgage
    current_account_balance
    employment_gross_income
    employment_payment
    employment_tax
    employment_nic
    employment
  ].freeze
  VALID_REMARK_ISSUES = %i[
    unknown_frequency
    amount_variation
    residual_balance
    multi_benefit
    multiple_employments
    refunds
  ].freeze

  # Irregular income categories and frequencies
  #
  ANNUAL_FREQUENCY = "annual".freeze
  STUDENT_LOAN = "student_loan".freeze
  VALID_IRREGULAR_INCOME_FREQUENCIES = [ANNUAL_FREQUENCY].freeze
  VALID_IRREGULAR_INCOME_TYPES = [STUDENT_LOAN].freeze

  # Date and bank holidays
  #
  DATE_REGEX = /^([12][9|0][0-9]{2}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01]))$/
  GOVUK_BANK_HOLIDAY_API_URL = "https://www.gov.uk/bank-holidays.json".freeze
  GOVUK_BANK_HOLIDAY_DEFAULT_GROUP = "england-and-wales".freeze

  # Frequencies
  #
  VALID_FREQUENCIES = %i[monthly four_weekly two_weekly weekly unknown].freeze
  NUMBER_OF_MONTHS_TO_AVERAGE = 3
end

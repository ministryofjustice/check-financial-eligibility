class Remarks
  attr_reader :remarks_hash

  # The types outgoings_childcare, outgoings_maintenance_out and outgoings_rent_or_mortgage are retained for compatibility with earlier versions of integration test spreadsheet
  # TODO:
  # Remove the above types when no longer required

  VALID_TYPES = %i[
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
  ].freeze
  VALID_ISSUES = %i[unknown_frequency amount_variation residual_balance].freeze

  def initialize
    @remarks_hash = {}
  end

  def add(new_type, new_issue, new_ids)
    validate_type_and_issue(new_type, new_issue)
    @remarks_hash[new_type] = {} unless @remarks_hash.key?(new_type)
    @remarks_hash[new_type][new_issue] = [] unless @remarks_hash[new_type].key?(new_issue)
    @remarks_hash[new_type][new_issue] += new_ids
  end

  def as_json
    @remarks_hash
  end

  private

  def validate_type_and_issue(type, issue)
    raise ArgumentError, "Invalid type: #{type}" unless VALID_TYPES.include?(type)
    raise ArgumentError, "Invalid issue: #{issue}" unless VALID_ISSUES.include?(issue)
  end
end

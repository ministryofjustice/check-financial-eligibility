class Remarks
  attr_reader :remarks_hash

  VALID_TYPES = %i[ other_income state_benfits outgoings ]
  VALID_ISSUES = %i[ unknown_frequency amount_variation ]

  def initialize
    @remarks_hash = {}
  end

  def add(new_type, new_issue, *new_ids)
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

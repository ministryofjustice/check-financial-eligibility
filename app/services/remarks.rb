class Remarks
  attr_reader :remarks_hash

  # The types outgoings_childcare, outgoings_maintenance_out and outgoings_rent_or_mortgage are retained for compatibility with earlier versions of integration test spreadsheet
  # TODO:
  # Remove the above types when no longer required

  def initialize(assessment_id)
    @assessment_id = assessment_id
    @remarks_hash = {}
  end

  def add(new_type, new_issue, new_ids)
    validate_type_and_issue(new_type, new_issue)
    @remarks_hash[new_type] = {} unless @remarks_hash.key?(new_type)
    @remarks_hash[new_type][new_issue] = [] unless @remarks_hash[new_type].key?(new_issue)
    @remarks_hash[new_type][new_issue] += new_ids
  end

  def as_json
    @remarks_hash.merge! ExplicitRemark.remarks_by_category(@assessment_id)
  end

private

  def validate_type_and_issue(type, issue)
    raise ArgumentError, "Invalid type: #{type}" unless CFEConstants::VALID_REMARK_TYPES.include?(type)
    raise ArgumentError, "Invalid issue: #{issue}" unless CFEConstants::VALID_REMARK_ISSUES.include?(issue)
  end
end

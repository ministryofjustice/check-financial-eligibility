module Exemptable
  def exempt_from_checking
    childcare_payment? && childcare_disallowed?
  end

  def childcare_payment?
    record_type == :outgoings_childcare
  end

  def childcare_disallowed?
    @assessment.disposable_income_summary.childcare.zero?
  end
end

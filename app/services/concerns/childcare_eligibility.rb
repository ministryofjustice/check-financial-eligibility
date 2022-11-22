module ChildcareEligibility
private

  def eligible_for_childcare_costs?
    applicant_has_dependant_child? && (applicant_is_employed? || applicant_has_student_loan?)
  end

  def applicant_has_dependant_child?
    assessment.dependants.any? do |dependant|
      assessment.submission_date.before?(dependant.becomes_adult_on)
    end
  end

  def applicant_is_employed?
    !!applicant&.employed?
  end

  def applicant_has_student_loan?
    student_loan_payments.any?
  end
end

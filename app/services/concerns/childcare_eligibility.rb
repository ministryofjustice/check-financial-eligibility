module ChildcareEligibility
private

  def eligible_for_childcare_costs?(person, submission_date)
    person_has_dependant_child?(person, submission_date) &&
      (person.employed? || person.has_student_loan?)
  end

  def person_has_dependant_child?(person, submission_date)
    person.dependants.any? do |dependant|
      submission_date.before?(dependant.becomes_adult_on)
    end
  end
end

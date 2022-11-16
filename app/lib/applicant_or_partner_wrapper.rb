# some rules treat applicant and partner as a single entity
# this class creates that concept so that rules code doesn't
# have to worry about the distinction betwewen them.
class ApplicantOrPartnerWrapper
  def initialize(applicant, partner)
    @applicant = applicant
    @partner = partner
  end

  def has_student_loan?
    @applicant.has_student_loan? || @partner.has_student_loan?
  end

  def employed?
    @applicant.employed? || @partner.employed?
  end

  def single?
    false
  end

  def dependants
    @applicant.dependants + @partner.dependants
  end
end

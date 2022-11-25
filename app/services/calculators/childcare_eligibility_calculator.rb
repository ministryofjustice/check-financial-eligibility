module Calculators
  class ChildcareEligibilityCalculator
    def self.call(applicant:, partner:, dependants:, submission_date:)
      new(applicant:, partner:, dependants:, submission_date:).call
    end

    def initialize(applicant:, partner:, dependants:, submission_date:)
      @applicant = applicant
      @partner = partner
      @dependants = dependants
      @submission_date = submission_date
    end

    def call
      at_least_one_child_dependant? && all_applicants_are_employed_or_students?
    end

  private

    def at_least_one_child_dependant?
      @dependants.any? do |dependant|
        @submission_date.before?(dependant.becomes_adult_on)
      end
    end

    def all_applicants_are_employed_or_students?
      [@applicant, @partner].compact.all? { _1.employed? || _1.is_student? }
    end
  end
end

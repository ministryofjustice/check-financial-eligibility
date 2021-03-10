module Decorators
  class ApplicantDecorator
    def initialize(applicant)
      @record = applicant
    end

    def as_json
      return nil if @record.nil?

      {
        date_of_birth: @record.date_of_birth,
        involvement_type: @record.involvement_type,
        has_partner_opponent: @record.has_partner_opponent,
        receives_qualifying_benefit: @record.receives_qualifying_benefit,
        self_employed: @record.self_employed
      }
    end
  end
end

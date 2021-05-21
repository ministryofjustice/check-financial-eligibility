module TestCase
  class Applicant
    def initialize(rows)
      @date_of_birth = rows.shift[3]
      @involvement_type = rows.shift[3]
      @has_partner_opponent = rows.shift[3]
      @receives_qualifying_benefit = rows.shift[3]
    end

    def url_method
      :assessment_applicant_path
    end

    def payload
      {
        applicant: {
          date_of_birth: @date_of_birth,
          involvement_type: @involvement_type,
          has_partner_opponent: @has_partner_opponent,
          receives_qualifying_benefit: @receives_qualifying_benefit
        }
      }
    end

    def empty?
      false
    end
  end
end

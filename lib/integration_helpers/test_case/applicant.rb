module TestCase
  class Applicant
    def initialize(rows)
      @rows = rows
      @rows.each { |row| populate_instance_vars(row) }
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
          receives_qualifying_benefit: @receives_qualifying_benefit,
        },
      }
    end

    def empty?
      false
    end

  private

    def populate_instance_vars(row)
      case row[2]
      when "date_of_birth"
        @date_of_birth = row[3]
      when "has_partner_opponent"
        @has_partner_opponent = row[3]
      when "receives_qualifying_benefit"
        @receives_qualifying_benefit = row[3]
      when "involvement_type"
        @involvement_type = row[3]
      end
    end
  end
end

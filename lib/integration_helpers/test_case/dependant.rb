module TestCase
  class Dependant
    def initialize(rows)
      @date_of_birth = rows.shift[3]
      @in_full_time_education = rows.shift[3]
      @relationship = rows.shift[3]
      @monthly_income = rows.shift[3]
      @assets_value = rows.shift[3]
    end

    def all_nil?
      @date_of_birth.nil? &&
        @in_full_time_education.nil? &&
        @relationship.nil? &&
        @monthly_income.nil? &&
        @assets_value.nil?
    end

    def payload
      {
        date_of_birth: @date_of_birth,
        in_full_time_education: @in_full_time_education,
        relationship: @relationship,
        monthly_income: @monthly_income,
        assets_value: @assets_value
      }
    end
  end
end

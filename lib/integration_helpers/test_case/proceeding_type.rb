module TestCase
  class ProceedingType
    def initialize(rows)
      @proceeding_type_code = rows.first[3]
      @client_involvement_type = rows.last[3]
    end

    def all_nil?
      @proceeding_type_code.nil? &&
        @client_involvement_type.nil?
    end

    def payload
      {
        ccms_code: @proceeding_type_code,
        client_involvement_type: @client_involvement_type,
      }
    end
  end
end

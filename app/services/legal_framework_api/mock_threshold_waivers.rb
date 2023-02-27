module LegalFrameworkAPI
  class MockThresholdWaivers
    def self.call(proceeding_type_details)
      new(proceeding_type_details).call
    end

    def initialize(proceeding_type_details)
      @proceeding_type_details = proceeding_type_details
    end

    def call
      {
        request_id: SecureRandom.uuid,
        success: true,
        proceedings: proceeding_response_details,
      }
    end

  private

    def proceeding_response_details
      proceeding_array = []
      @proceeding_type_details.each { |pt_detail| proceeding_array << detail_hash(pt_detail) }
      proceeding_array
    end

    def detail_hash(pt_detail)
      {
        ccms_code: pt_detail[:ccms_code],
        matter_type: matter_type(pt_detail),
        gross_income_upper: waived?(pt_detail),
        disposable_income_upper: waived?(pt_detail),
        capital_upper: waived?(pt_detail),
        client_involvement_type: pt_detail[:client_involvement_type],
      }
    end

    def matter_type(pt_detail)
      case pt_detail[:ccms_code]
      when /^DA/
        "Domestic abuse"
      when /^SE/
        "Children - section 8"
      else
        raise "Unrecognised CCMS code: #{pt_detail[:ccms_code]}"
      end
    end

    def waived?(pt_detail)
      matter_type(pt_detail) == "Domestic abuse" && pt_detail[:client_involvement_type] == "A" ? true : false
    end
  end
end

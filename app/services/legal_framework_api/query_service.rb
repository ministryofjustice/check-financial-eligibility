module LegalFrameworkAPI
  class QueryService
    ENDPOINT = 'proceeding_types/threshold_waivers'.freeze
    MATTER_TYPES_MAP = {
      'Domestic abuse' => 'domestic_abuse',
      'Children - section 8' => 'section8'
    }.freeze

    @proceeding_types = {}

    def self.waived?(ccms_code, threshold_type)
      new(ccms_code, threshold_type).waived?
    end

    def self.matter_type(ccms_code)
      new(ccms_code).matter_type
    end

    class << self
      attr_reader :proceeding_types
    end

    def initialize(ccms_code, threshold_type = nil)
      @ccms_code = ccms_code
      @threshold_type = threshold_type
      populate_proceeding_types(ccms_code)
    end

    def waived?
      # return the value for that threshold type, or false if an unknown threshold type
      QueryService.proceeding_types.fetch(@ccms_code)[@threshold_type] || false
    end

    def matter_type
      QueryService.proceeding_types.fetch(@ccms_code)[:matter_type]
    end

  private

    def populate_proceeding_types(ccms_code)
      return if QueryService.proceeding_types.key?(ccms_code)

      result = query_legal_framework_api
      QueryService.proceeding_types.merge!(result)
    end

    def query_legal_framework_api
      raw_response = post_request
      raise ResponseError, raw_response unless raw_response.status == 200

      parsed_response = parse_json_response(raw_response.body)
      format_for_proceeding_types(parsed_response)
    end

    def format_for_proceeding_types(response)
      # reformats returned hash:
      # {
      #   :request_id=>"e76bd31f-dd62-444f-9d7d-a731b40b7eea",
      #   :proceeding_types=> [
      #     {
      #       ccms_code: "DA001",
      #       matter_type: "Domestic abuse",
      #       capital_upper: true,
      #       disposable_income_upper: true,
      #       gross_income_upper: true
      #     },
      #     {
      #       ccms_code: "SE013",
      #       matter_type: "Children - section 8",
      #       capital_upper: false,
      #       disposable_income_upper: false,
      #       gross_income_upper: false
      #     }
      #   ]
      # }
      #
      # into hash suitable form merging into @proceeding_types
      # {
      #   DA001: {
      #     matter_type: "domestic_abuse",
      #     capital_upper: true,
      #     disposable_income_upper: true,
      #     gross_income_upper: true
      #   },
      #   SE013: {
      #     matter_type: "section8",
      #     capital_upper: false,
      #     disposable_income_upper: false,
      #     gross_income_upper: false
      #   }
      # }
      formatted_hash = {}
      response[:proceeding_types].each do |pt|
        key = pt[:ccms_code].to_sym
        pt.delete(:ccms_code)
        pt[:matter_type] = MATTER_TYPES_MAP[pt[:matter_type]]
        formatted_hash[key] = pt
      end
      formatted_hash
    end

    def parse_json_response(response_body)
      JSON.parse(response_body, symbolize_names: true)
    end

    def post_request
      conn.post do |request|
        request.url ENDPOINT
        request.headers['Content-Type'] = 'application/json'
        request.body = request_body
      end
    end

    def host
      Rails.configuration.x.legal_framework_api_host
    end

    def request_body
      {
        request_id: SecureRandom.uuid,
        proceeding_types: [@ccms_code]
      }.to_json
    end

    def conn
      @conn ||= Faraday.new(url: host, headers:)
    end

    def headers
      {
        'Content-Type' => 'application/json'
      }
    end
  end
end

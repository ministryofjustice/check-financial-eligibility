module LegalFrameworkAPI
  class ThresholdWaivers
    ENDPOINT = "threshold_waivers".freeze

    def self.call(proceeding_type_details)
      new(proceeding_type_details).call
    end

    def initialize(proceeding_type_details)
      @proceeding_type_details = proceeding_type_details
      @request_id = SecureRandom.uuid
    end

    def call
      query_legal_framework_api
    end

  private

    def query_legal_framework_api
      raw_response = post_request
      raw_response.body
    end

    def post_request
      conn.post do |request|
        request.url ENDPOINT
        request.body = request_payload
      end
    end

    def request_payload
      {
        request_id: @request_id,
        proceedings: @proceeding_type_details,
      }
    end

    def conn
      @conn ||= Faraday.new(url: host) do |faraday|
        faraday.request :json

        faraday.response :raise_error
        faraday.response :json, parser_options: { symbolize_names: true }
      end
    end

    def host
      Rails.configuration.x.legal_framework_api_host
    end
  end
end

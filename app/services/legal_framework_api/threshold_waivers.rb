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
      raise ResponseError, raw_response unless raw_response.status == 200

      JSON.parse(raw_response.body, symbolize_names: true)
    end

    def post_request
      conn.post do |request|
        request.url ENDPOINT
        request.headers["Content-Type"] = "application/json"
        request.body = request_payload
      end
    end

    def request_payload
      {
        request_id: @request_id,
        proceedings: @proceeding_type_details,
      }.to_json
    end

    def conn
      @conn ||= Faraday.new(url: host, headers:)
    end

    def headers
      {
        "Content-Type" => "application/json",
      }
    end

    def host
      Rails.configuration.x.legal_framework_api_host
    end
  end
end

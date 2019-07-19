module IntegrationTests
  class ServiceClient
    def initialize(base_url)
      @base_url = base_url
    end

    def create_assessment(payload)
      post('/assessments', payload)
    end

    def create_applicant(assessment_id, payload)
      post("/assessments/#{assessment_id}/applicant", payload)
    end

    def create_dependants(assessment_id, payload)
      post("/assessments/#{assessment_id}/dependants", payload)
    end

    def create_capital(assessment_id, payload)
      post("/assessments/#{assessment_id}/capitals", payload)
    end

    def create_vehicles(assessment_id, payload)
      post("/assessments/#{assessment_id}/vehicles", payload)
    end

    def create_properties(assessment_id, payload)
      post("/assessments/#{assessment_id}/properties", payload)
    end

    def create_income(assessment_id, payload)
      post("/assessments/#{assessment_id}/income", payload)
    end

    def create_outgoings(assessment_id, payload)
      post("/assessments/#{assessment_id}/outgoings", payload)
    end

    private

    attr_reader :base_url

    def post(path, payload)
      url = URI(File.join(base_url, path))
      http = Net::HTTP.new(url.host, url.port)
      request = Net::HTTP::Post.new(url)
      request['Content-Type'] = 'application/json'
      request.body = payload.to_json
      response = http.request(request)
      parse_response(response)
    end

    def parse_response(response)
      raise "Request Failed: #{response.message} (#{response.code}) #{response.body}" unless response.is_a?(Net::HTTPOK)

      JSON.parse(response.body, symbolize_names: true)
    end
  end
end

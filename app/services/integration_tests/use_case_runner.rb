module IntegrationTests
  class UseCaseRunner
    def self.call(*args)
      new(*args).call
    end

    def initialize(base_url, payload)
      @base_url = base_url
      @payload = payload
    end

    def call
      create_application
      # TODO: call endpoint to get result of assessment
    end

    private

    attr_reader :base_url, :payload
    attr_accessor :assessment_id

    def create_application
      assessment
      applicant
      dependants
      capital
      vehicles
      properties
      income
      outgoings
    end

    def assessment
      response = client.create_assessment(payload[:assessment])
      self.assessment_id = response[:objects].first[:id]
    end

    def applicant
      client.create_applicant(
        assessment_id,
        assessment_id: assessment_id,
        applicant: payload[:applicant]
      )
    end

    def dependants
      client.create_dependants(
        assessment_id,
        assessment_id: assessment_id,
        dependants: payload[:dependants]
      )
    end

    def capital
      client.create_capital(assessment_id, payload[:capital].merge(assessment_id: assessment_id))
    end

    def vehicles
      client.create_vehicles(assessment_id, vehicles: payload[:vehicles])
    end

    def properties
      client.create_properties(
        assessment_id,
        assessment_id: assessment_id,
        properties: payload[:properties]
      )
    end

    def income
      client.create_income(assessment_id, payload[:income])
    end

    def outgoings
      client.create_outgoings(assessment_id, outgoings: payload[:outgoings])
    end

    def client
      @client = ServiceClient.new(base_url)
    end
  end
end

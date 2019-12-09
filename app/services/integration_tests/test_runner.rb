module IntegrationTests
  class TestRunner
    STEPS = {
      applicant: ->(assessment_id) { urls.assessment_applicant_path(assessment_id) },
      capital: ->(assessment_id) { urls.assessment_capitals_path(assessment_id) },
      vehicles: ->(assessment_id) { urls.assessment_vehicles_path(assessment_id) },
      properties: ->(assessment_id) { urls.assessment_properties_path(assessment_id) },
      other_incomes: ->(assessment_id) { urls.assessment_other_incomes_path(assessment_id) }
      # TODO: uncomment when running non-passported test cases
      # earned_income: ->(assessment_id) { urls.assessment_earned_income_path(assessment_id) }
      # state_benefits: ->(assessment_id) { urls.assessment_state_benefits_path(assessment_id) }
      # outgoings: ->(assessment_id) { urls.assessment_outgoings_path(assessment_id) }
      # dependants: ->(assessment_id) { urls.assessment_dependants_path(assessment_id) },
    }.freeze

    def self.urls
      Rails.application.routes.url_helpers
    end

    def self.steps(assessment_id, payload)
      STEPS.keys.map do |step|
        new(step, assessment_id, payload)
      end
    end

    attr_reader :step, :assessment_id, :payload

    def initialize(step, assessment_id, payload)
      @step = step
      @assessment_id = assessment_id
      @payload = payload
    end

    def url
      STEPS[step].call(assessment_id)
    end

    def params
      case step
      when :capital
        payload[:capital].slice(:bank_accounts, :non_liquid_capital)
      else
        payload.slice(step)
      end
    end
  end
end

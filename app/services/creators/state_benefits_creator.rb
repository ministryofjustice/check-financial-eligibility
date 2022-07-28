module Creators
  class StateBenefitsCreator < BaseCreator
    attr_accessor :assessment_id

    delegate :gross_income_summary, to: :assessment

    attr_reader :result

    def initialize(assessment_id:, state_benefits_params:)
      super()
      @assessment_id = assessment_id
      @state_benefits_params = state_benefits_params
      @result = []
    end

    def call
      if json_validator.valid?
        create_records
      else
        errors.concat(json_validator.errors)
      end
      self
    end

  private

    def create_records
      ActiveRecord::Base.transaction do
        assessment
        create_state_benefits
      rescue CreationError => e
        self.errors = e.errors
      end
    end

    def create_state_benefits
      return if state_benefits.empty?

      state_benefits.each do |state_benefit_attributes|
        @result << create_state_benefit(state_benefit_attributes)
      end
    rescue ActiveRecord::RecordInvalid => e
      raise CreationError, e.record.errors.full_messages
    end

    def create_state_benefit(state_benefit_attributes)
      state_benefit = StateBenefit.generate!(gross_income_summary, state_benefit_attributes[:name])
      state_benefit_attributes[:payments].each do |payment|
        state_benefit.state_benefit_payments.create!(
          payment_date: payment[:date],
          amount: payment[:amount],
          client_id: payment[:client_id],
          flags: generate_flags(payment),
        )
      end
      state_benefit
    end

    def generate_flags(hash)
      return false if hash[:flags].blank?

      hash[:flags].map { |k, v| k if v.eql?(true) }.compact
    end

    def state_benefits
      @state_benefits ||= JSON.parse(@state_benefits_params, symbolize_names: true)[:state_benefits]
    end

    def json_validator
      @json_validator ||= JsonValidator.new("state_benefits", @state_benefits_params)
    end
  end
end

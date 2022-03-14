module Creators
  class StateBenefitsCreator < BaseCreator
    attr_accessor :assessment_id

    delegate :gross_income_summary, to: :assessment

    attr_reader :result

    def initialize(assessment_id:, state_benefits: [])
      super()
      @assessment_id = assessment_id
      @state_benefits = state_benefits[:state_benefits]
      @result = []
    end

    def call
      create_records
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
      return if @state_benefits.empty?

      @state_benefits.each do |state_benefit_params|
        @result << create_state_benefit(state_benefit_params)
      end
    end

    def create_state_benefit(state_benefit_params)
      state_benefit = StateBenefit.generate!(gross_income_summary, state_benefit_params[:name])
      state_benefit_params[:payments].each do |payment_params|
        state_benefit.state_benefit_payments.create!(
          payment_date: payment_params[:date],
          amount: payment_params[:amount],
          client_id: payment_params[:client_id],
          flags: generate_flags(payment_params),
        )
      end
      state_benefit
    end

    def generate_flags(hash)
      return false if hash[:flags].blank?

      hash[:flags].map { |k, v| k if v.eql?(true) }.compact
    end
  end
end

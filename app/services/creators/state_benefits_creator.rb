module Creators
  class StateBenefitsCreator < BaseCreator
    attr_accessor :assessment_id

    delegate :gross_income_summary, to: :assessment

    attr_reader :result

    def initialize(assessment_id:, state_benefits: [])
      @assessment_id = assessment_id
      @state_benefits = state_benefits[:state_benefits]
      @result = []
    end

    def call
      create
      self
    end

    private

    def create
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
          client_id: payment_params[:client_id]
        )
      end
      state_benefit
    end
  end
end

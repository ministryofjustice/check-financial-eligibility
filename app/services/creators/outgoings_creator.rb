module Creators
  class OutgoingsCreator < BaseCreator
    OUTGOING_KLASSES = {
      childcare: Outgoings::Childcare,
      housing_costs: Outgoings::HousingCost,
      maintenance: Outgoings::Maintenance
    }.freeze

    def initialize(assessment_id:, outgoings:)
      @assessment_id = assessment_id
      @outgoings = outgoings
    end

    def call
      ActiveRecord::Base.transaction do
        @outgoings.keys.each { |key| create_outgoing_collection(key) }
      end
      self
    end

    def outgoings
      disposable_income_summary.outgoings
    end

    private

    def create_outgoing_collection(key)
      payments = @outgoings[key]
      klass = OUTGOING_KLASSES[key]
      payments.each do |payment_params|
        klass.create! payment_params.merge(disposable_income_summary: disposable_income_summary)
      end
    end

    def disposable_income_summary
      @disposable_income_summary ||= find_or_create_disposable_income_summary
    end

    def find_or_create_disposable_income_summary
      assessment.disposable_income_summary || assessment.create_disposable_income_summary
    end
  end
end

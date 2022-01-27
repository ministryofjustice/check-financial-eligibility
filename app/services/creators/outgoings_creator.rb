module Creators
  class OutgoingsCreator < BaseCreator
    def initialize(assessment_id:, outgoings:)
      super()
      @assessment_id = assessment_id
      @outgoings = outgoings
    end

    def call
      ActiveRecord::Base.transaction do
        @outgoings.each { |outgoing| create_outgoing_collection(outgoing) }
      end
      self
    end

    private

    def create_outgoing_collection(outgoing)
      klass = CFEConstants::OUTGOING_KLASSES[outgoing[:name].to_sym]
      payments = outgoing[:payments]
      payments.each do |payment_params|
        klass.create! payment_params.merge(disposable_income_summary:)
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

module Creators
  class OutgoingsCreator < BaseCreator
    def initialize(assessment_id:, outgoings_params:)
      super()
      @assessment_id = assessment_id
      @outgoings_params = outgoings_params
    end

    def call
      if json_validator.valid?
        ActiveRecord::Base.transaction do
          outgoings.each { |outgoing| create_outgoing_collection(outgoing) }
        end
      else
        errors.concat(json_validator.errors)
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
    rescue CreationError => e
      self.errors = e.errors
    end

    def disposable_income_summary
      @disposable_income_summary ||= find_or_create_disposable_income_summary
    end

    def find_or_create_disposable_income_summary
      assessment.disposable_income_summary || assessment.create_disposable_income_summary
    end

    def outgoings
      @outgoings ||= JSON.parse(@outgoings_params, symbolize_names: true)[:outgoings]
    end

    def json_validator
      @json_validator ||= JsonValidator.new("outgoings", @outgoings_params)
    end
  end
end

module Creators
  class OutgoingsCreator
    Result = Struct.new :errors, keyword_init: true do
      def success?
        errors.empty?
      end
    end
    class << self
      def call(assessment:, outgoings_params:)
        json_validator = JsonValidator.new("outgoings", outgoings_params)
        if json_validator.valid?
          ActiveRecord::Base.transaction do
            outgoings_params[:outgoings].each { |outgoing| create_outgoing_collection(assessment, outgoing) }
          end
          Result.new(errors: []).freeze
        else
          Result.new(errors: json_validator.errors).freeze
        end
      rescue ActiveRecord::RecordInvalid => e
        Result.new(errors: e.record.errors.full_messages).freeze
      end

    private

      def create_outgoing_collection(assessment, outgoing)
        klass = CFEConstants::OUTGOING_KLASSES[outgoing[:name].to_sym]
        payments = outgoing[:payments]
        payments.each do |payment_params|
          klass.create! payment_params.merge(disposable_income_summary: assessment.disposable_income_summary)
        end
      end
    end
  end
end

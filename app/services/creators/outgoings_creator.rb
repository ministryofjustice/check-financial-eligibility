module Creators
  class OutgoingsCreator
    Result = Struct.new :errors, keyword_init: true do
      def success?
        errors.empty?
      end
    end
    class << self
      def call(disposable_income_summary:, outgoings_params:)
        ActiveRecord::Base.transaction do
          outgoings_params[:outgoings].each { |outgoing| create_outgoing_collection(disposable_income_summary, outgoing) }
        end
        Result.new(errors: []).freeze
      rescue ActiveRecord::RecordInvalid => e
        Result.new(errors: e.record.errors.full_messages).freeze
      end

    private

      def create_outgoing_collection(disposable_income_summary, outgoing)
        klass = CFEConstants::OUTGOING_KLASSES[outgoing[:name].to_sym]
        payments = outgoing[:payments]
        payments.each do |payment_params|
          klass.create! payment_params.merge(disposable_income_summary:)
        end
      end
    end
  end
end

module Creators
  class ProceedingTypesCreator
    Result = Struct.new :errors, keyword_init: true do
      def success?
        errors.empty?
      end
    end

    class << self
      def call(assessment:, proceeding_types_params:)
        create_records assessment:, proceeding_types_params:
      end

    private

      def create_records(assessment:, proceeding_types_params:)
        create_proceeding_types(assessment:, proceeding_types_params:)
        Result.new(errors: []).freeze
      end

      def create_proceeding_types(assessment:, proceeding_types_params:)
        assessment.proceeding_types.create!(proceeding_types_attributes(proceeding_types_params))
      end

      def proceeding_types_attributes(proceeding_types_params)
        proceeding_types_params[:proceeding_types]
      end
    end
  end
end

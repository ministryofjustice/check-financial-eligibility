module Creators
  class BaseCreator
    attr_writer :errors

    def self.call(**args)
      new(**args).call
    end

    def errors
      @errors ||= []
    end

    def success?
      errors.empty?
    end

    def assessment
      @assessment ||= Assessment.find_by(id: @assessment_id) || (raise CreationError, ['No such assessment id'])
    end

    class CreationError < StandardError
      attr_reader :errors

      def initialize(errors)
        @errors = errors
        super
      end
    end
  end
end

module Creators
  class BaseCreator
    attr_writer :errors

    def self.call(*args)
      new(*args).call
    end

    def errors
      @errors ||= []
    end

    def success?
      errors.empty?
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

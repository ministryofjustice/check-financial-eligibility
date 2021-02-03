module Decorators
  class ErrorDecorator
    def initialize(message_or_error)
      @message_or_error = message_or_error
      @message = standardize_message
    end

    def as_json
      {
        errors: [@message],
        success: false
      }
    end

    private

    def standardize_message
      case @message_or_error.class.to_s
      when 'String'
        @message_or_error
      when 'CheckFinancialEligibilityError'
        @message_or_error.message
      else
        "#{@message_or_error.class}: #{@message_or_error.message}\n#{@message_or_error.backtrace}"
      end
    end
  end
end

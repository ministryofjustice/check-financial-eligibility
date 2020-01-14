module Decorators
  class ErrorDecorator
    def initialize(message)
      @message = message
    end

    def as_json
      {
        "errors": [@message],
        "success": false
      }
    end
  end
end

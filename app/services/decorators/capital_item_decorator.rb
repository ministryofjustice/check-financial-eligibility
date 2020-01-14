module Decorators
  class CapitalItemDecorator
    attr_reader :assessment

    def initialize(record)
      @record = record
    end

    def as_json
      {
        description: @record.description,
        value: @record.value
      }
    end
  end
end

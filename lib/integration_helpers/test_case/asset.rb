module TestCase
  class Asset
    def initialize(description:, amount:)
      @description = description
      @amount = amount
    end

    def all_nil?
      @description.nil? && @amount.nil?
    end

    def payload
      {
        description: @description,
        value: @amount,
      }
    end
  end
end

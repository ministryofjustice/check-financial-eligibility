module TestCase
  class Property
    def initialize(type, rows)
      @type = type
      @value = rows[0][3]
      @outstanding_mortgage = rows[1][3]
      @percentage_owned = rows[2][3]
      @shared_with_housing_assoc = rows[3][3]
    end

    def payload
      return nil if empty_values?

      {
        value: @value,
        outstanding_mortgage: @outstanding_mortgage,
        percentage_owned: @percentage_owned,
        shared_with_housing_assoc: @shared_with_housing_assoc
      }
    end

    private

    def empty_values?
      @value.nil? && @outstanding_mortgage.nil? && @percentage_owned.nil? && @shared_with_housing_assoc.nil?
    end
  end
end

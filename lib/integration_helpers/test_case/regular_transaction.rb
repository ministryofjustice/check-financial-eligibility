module TestCase
  class RegularTransaction
    attr_reader :category, :amount, :frequency

    def initialize(category, data)
      @category = category
      @amount = data&.dig(0)&.dig(3)
      @frequency = data&.dig(1)&.dig(3)
    end

    def payload
      return nil if empty_values?

      {
        category:,
        operation:,
        amount:,
        frequency:,
      }
    end

  private

    def operation
      case category
      when *CFEConstants::VALID_REGULAR_INCOME_CATEGORIES
        "credit"
      when *CFEConstants::VALID_OUTGOING_CATEGORIES
        "debit"
      else
        raise ArgumentError, "unexpected category \"#{category}\" with no available operation"
      end
    end

    def empty_values?
      category.blank? && amount.blank? && frequency.blank?
    end
  end
end

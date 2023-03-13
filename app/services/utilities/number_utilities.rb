module Utilities
  class NumberUtilities
    class << self
      def negative_to_zero(value)
        [value, 0.0].max
      end
    end
  end
end

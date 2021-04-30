module TestCase
  module V3
    class ExpectedResult
      attr_reader :result_set

      def initialize(rows)
        @rows = rows
        @result_set = {}
        populate
      end

      private

      def populate
        @rows.shift
        col1 = @rows.first[0]
        while @rows.any?
          row = @rows.shift
          col1 = row.first if row.first.present?
          col2 = row[1]
          value = row[3]
          @result_set["#{col1}_#{col2}"] = value
        end
      end
    end
  end
end

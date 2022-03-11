module TestCase
  module V4
    class RemarksComparer
      def self.call(expected, actual, verbosity)
        new(expected, actual, verbosity).call
      end

      def initialize(expected, actual, verbosity)
        @expected = expected
        @actual = actual
        @verbosity = verbosity
        @header_pattern = "%58s  %-26s %-s"
        @result = true
      end

      def call
        return true if @expected.blank?

        compare_remarks

        @result
      end

      def silent?
        @verbosity.zero?
      end

      def compare_remarks
        puts "Remarks >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>".green unless silent?

        @expected.each { |remark_type, remark_type_hash| compare_remark_type(remark_type, remark_type_hash) }
      end

      def compare_remark_type(type, hash)
        hash.each do |issue, _ids|
          puts "before check"
          print_remark_line(type, issue)
          next if @actual&.dig(type)&.dig(issue) == @expected[type][issue]

          @result = false
          # print_remark_line(type, issue)
          print_remark_line(type, issue) unless silent?
        end
      end

      def print_remark_line(type, issue)
        # OLD STYLE
        actual = @actual&.dig(type)&.dig(issue)&.each { |id| puts "    #{id}" }
        expected = @expected[type][issue].each { |id| puts "    #{id}" }
        color = :green
        color = :red unless actual.to_s == expected.to_s
        color = :blue if expected.nil?
        legend = "application employment remarks"
        verbose sprintf(@header_pattern, legend, expected, actual), color

        # NEW STYLE
        # color = :red
        # puts "#{type}/#{issue}".__send__(color)
        # puts "  expected:"
        # @expected[type][issue].each { |id| puts "    #{id}" }
        # puts "  actual:"
        # @actual&.dig(type)&.dig(issue)&.each { |id| puts "    #{id}" }
        # puts "  "
      end

      def verbose(string, color = :green)
        puts string.__send__(color) unless silent?
        @result = false if color == :red
      end
    end
  end
end

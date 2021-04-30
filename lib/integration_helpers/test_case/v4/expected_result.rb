module TestCase
  module V4
    class ExpectedResult
      attr_reader :result_set

      def initialize(rows)
        @rows = rows
        @result_set = {}
        @rows.shift
        populate
      end

      def compare(actual_result, _verbosity_level)
        # instantiate the Resultcomparer here and call
        puts ">>>>>>>>>>>> actual_result #{__FILE__}:#{__LINE__} <<<<<<<<<<<<".yellow
        pp actual_result
        puts ">>>>>>>>>>>> expected_results #{__FILE__}:#{__LINE__} <<<<<<<<<<<<".yellow
        pp @result_set
      end

      private

      def populate
        while @rows.any?
          col1 = @rows.first[0]
          extracted_rows = extract_rows
          __send__(col1, extracted_rows)
        end
      end

      def extract_rows
        row_index = @rows.index { |r| r.first.present? && r.first != @rows.first.first }
        row_index.nil? ? @rows : @rows.shift(row_index)
      end

      def assessment(rows) # rubocop:disable Metrics/MethodLength
        hash = {
          matter_types: [],
          proceeding_types: {}
        }
        while rows.any?
          case rows.first[1]
          when 'matter_types'
            store_matter_types(hash, extract_matter_type_rows(rows))
          when /^proceeding_type:/
            store_proceeding_types(hash, extract_proceeding_type_rows(rows))
          else
            hash[rows.first[1].to_sym] = rows.first[3]
            rows.shift
          end
        end
        @result_set[:assessment] = hash
      end

      def store_matter_types(hash, rows)
        while rows.any?
          row = rows.shift
          hash[:matter_types] << { row[2].to_sym => row[3] }
        end
      end

      def store_proceeding_types(hash, rows)
        # hash[:proceeding_types][ptc] = { result: rows.first[3]}
        while rows.any?
          row = rows.shift
          if row[1] =~ /^proceeding_type:\s([A-Z]{2}[0-9]{3})$/
            ptc = Regexp.last_match(1)
            hash[:proceeding_types][ptc] = { result: row[3] }
            next
          end
          hash[:proceeding_types][ptc][row[2].to_sym] = row[3]
        end
      end

      def extract_matter_type_rows(rows)
        row_index = rows.index { |r| r[1].present? && r[1] != 'matter_types' }
        rows.shift(row_index)
      end

      def extract_proceeding_type_rows(rows)
        row_index = rows.index { |r| r[0].present? }
        row_index.nil? ? rows : rows.shift(row_index)
      end

      def store_standard_expectations(section_name, rows)
        hash = {}
        while rows.any?
          row = rows.shift
          hash[row[1].to_sym] = row[3]
        end
        @result_set[section_name] = hash
      end

      def gross_income_summary(rows)
        store_standard_expectations(:gross_income_summary, rows)
      end

      def disposable_income_summary(rows)
        store_standard_expectations(:disposable_income_summary, rows)
      end

      def capital(rows)
        store_standard_expectations(:capital, rows)
      end

      def monthly_income_equivalents(rows)
        store_standard_expectations(:monthly_income_equivalents, rows)
      end

      def monthly_outgoing_equivalents(rows)
        store_standard_expectations(:monthly_outgoing_equivalents, rows)
      end

      def deductions(rows)
        store_standard_expectations(:deductions, rows)
      end
    end
  end
end

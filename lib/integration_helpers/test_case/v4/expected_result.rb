module TestCase
  module V4
    class ExpectedResult
      attr_reader :result_set

      def initialize(rows)
        @rows = rows
        @result_set = {}
        @rows.shift
        populate
        puts ">>>>>>>>>  #{__FILE__}:#{__LINE__} <<<<<<<<<<".yellow
        ap @result_set
      end

      def compare(actual_result, verbosity_level)
        ResultComparer.call(actual_result, @result_set, verbosity_level)
      end

    private

      def populate
        while @rows.any?
          col1 = @rows.first[0]
          extracted_rows = extract_rows
          __send__(col1, extracted_rows)
        end
      end

      def remarks(rows)
        hash = {}
        current_issue = nil
        current_type = nil
        while rows.any?
          row = rows.shift
          _unused, type, issue, id = row
          if type.present?
            current_type = type.to_sym
            hash[current_type] = {}
          end
          if issue.present?
            current_issue = issue.to_sym
            hash[current_type][current_issue] = []
          end

          hash[current_type][current_issue] << id
        end
        @result_set[:remarks] = hash
      end

      def extract_rows
        row_index = @rows.index { |r| r.first.present? && r.first != @rows.first.first }
        row_index.nil? ? @rows : @rows.shift(row_index)
      end

      def assessment(rows)
        hash = {
          matter_types: [],
          proceeding_types: {},
        }
        while rows.any?
          case rows.first[1]
          when "matter_types"
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
          next if row[2].nil?

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
        row_index = rows.index { |r| r[1].present? && r[1] != "matter_types" }
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

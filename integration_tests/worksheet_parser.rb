module IntegrationTests
  class WorksheetParser
    SKIP_ROWS = 2

    ARRAYS = %w[
      dependants
      wage_slips
      benefits
      outgoings
      additional_properties
      vehicles
      bank_accounts
      non_liquid_capital
    ].freeze

    def self.call(worksheet)
      new(worksheet).call
    end

    def initialize(worksheet)
      @worksheet = worksheet
    end

    def call
      parsed_rows.merge(
        test_name: rows.first.first,
        test_description: rows.first.second
      )
    end

    private

    attr_reader :worksheet
    attr_accessor :previous_cell1, :previous_cell2

    def rows
      @rows ||= worksheet.to_a
    end

    def parsed_rows
      self.previous_cell1 = nil
      self.previous_cell2 = nil
      rows[SKIP_ROWS..-1]
        .each_with_object({}) { |row, payload| parse_row(row, payload) }
        .deep_symbolize_keys
    end

    def parse_row(row, payload)
      row_extractor = RowExtractor.new(
        row: row,
        previous_cell1: previous_cell1,
        previous_cell2: previous_cell2,
        payload: payload
      )

      RowParser.call(
        hash_receiver: row_extractor.hash_receiver,
        object_name: row_extractor.object_name,
        attribute: row_extractor.attribute,
        value: row_extractor.value
      )

      self.previous_cell1 = row_extractor.cell1
      self.previous_cell2 = row_extractor.cell2
    end

    class RowExtractor
      attr_accessor :payload, :cell1, :cell2, :cell3, :value

      def initialize(row:, previous_cell1:, previous_cell2:, payload:)
        cell1, cell2, cell3, value = row
        @cell1 = cell1.to_s.parameterize.underscore.presence || previous_cell1
        @cell2 = cell2.to_s.parameterize.underscore.presence || previous_cell2
        @cell3 = cell3.to_s.parameterize.underscore
        @payload = payload
        @value = value
      end

      def hash_receiver
        return payload unless sub_object?

        payload[cell1] = {} unless payload[cell1]
        payload[cell1]
      end

      def object_name
        sub_object? ? cell2 : cell1
      end

      def attribute
        sub_object? ? cell3 : cell2
      end

      private

      def sub_object?
        cell3.present?
      end
    end

    class RowParser
      attr_accessor :hash_receiver, :object_name, :attribute, :value

      def self.call(*args)
        new(*args).call
      end

      def initialize(hash_receiver:, object_name:, attribute:, value:)
        @hash_receiver = hash_receiver
        @object_name = object_name
        @attribute = attribute
        @value = value
      end

      def call
        create_object
        object[attribute] = parsed_value
      end

      private

      def parsed_value
        return false if value.to_s.casecmp('false').zero?

        return true if value.to_s.casecmp('true').zero?

        value
      end

      def object
        @object ||= array? ? array_item : hash_receiver[object_name]
      end

      def array_item
        hash_receiver[object_name] << {} if hash_receiver[object_name].last.key?(attribute)
        hash_receiver[object_name].last
      end

      def create_object
        return if hash_receiver[object_name]

        hash_receiver[object_name] = array? ? [{}] : {}
      end

      def array?
        object_name.in?(ARRAYS)
      end
    end
  end
end

module IntegrationTests
  class WorksheetParser
    SKIP_ROWS = 2

    ARRAYS = %w[
      dependants
      applicant_income
      applicant_benefits
      applicant_outgoings
      property
      liquid_capital_bank_accts
      valuable_items
      non_liquid_capital
      vehicles
    ].freeze

    def self.call(worksheet)
      new(worksheet).call
    end

    def initialize(worksheet)
      @worksheet = worksheet
    end

    def call
      parsed_rows.merge(
        test_name: worksheet.rows.first.first,
        test_description: worksheet.rows.first.second
      )
    end

    private

    attr_reader :worksheet
    attr_accessor :previous_cell1, :previous_cell2

    def parsed_rows
      self.previous_cell1 = nil
      self.previous_cell2 = nil
      worksheet
        .rows[SKIP_ROWS..-1]
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
        value: row_extractor.value,
        notes: row_extractor.notes
      )

      self.previous_cell1 = row_extractor.cell1
      self.previous_cell2 = row_extractor.cell2
    end

    class RowExtractor
      attr_accessor :payload, :cell1, :cell2, :cell3, :value, :notes

      def initialize(row:, previous_cell1:, previous_cell2:, payload:)
        cell1, cell2, cell3, value, notes = row
        @cell1 = cell1.parameterize.underscore.presence || previous_cell1
        @cell2 = cell2.parameterize.underscore.presence || previous_cell2
        @cell3 = cell3.parameterize.underscore
        @payload = payload
        @value = value
        @notes = notes
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
      attr_accessor :hash_receiver, :object_name, :attribute, :value, :notes

      def self.call(*args)
        new(*args).call
      end

      def initialize(hash_receiver:, object_name:, attribute:, value:, notes:)
        @hash_receiver = hash_receiver
        @object_name = object_name
        @attribute = attribute
        @value = value
        @notes = notes
      end

      def call
        create_object
        object[attribute] = value
        object["#{attribute}_notes"] = notes if notes.present?
      end

      private

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

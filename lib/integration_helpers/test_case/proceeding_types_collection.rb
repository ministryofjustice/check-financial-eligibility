require Rails.root.join("lib/integration_helpers/test_case/proceeding_type.rb")

module TestCase
  class ProceedingTypesCollection
    def initialize(rows)
      @proceeding_types = []
      populate_proceeding_types(rows)
    end

    def url_method
      :assessment_proceeding_types_path
    end

    def payload
      {
        proceeding_types: @proceeding_types.map(&:payload),
      }
    end

    def empty?
      false
    end

  private

    def populate_proceeding_types(rows)
      loop do
        break if rows.empty?

        proceeding_type_data = rows.shift(2)
        proceeding_type = ::TestCase::ProceedingType.new(proceeding_type_data)
        @proceeding_types << proceeding_type unless proceeding_type.all_nil?
      end
    end
  end
end

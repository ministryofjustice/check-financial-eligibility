module TestCase
  class Worksheet # rubocop:disable Metrics/ClassLength
    attr_reader :assessment,
                :applicant,
                :capitals,
                :cash_transactions,
                :dependants,
                :employment_income,
                :expected_results,
                :irregular_income,
                :other_incomes,
                :outgoings,
                :properties,
                :state_benefits,
                :submission_date,
                :test_name,
                :vehicle,
                :worksheet_name

    PAYLOAD_OBJECTS = %i[
      applicant
      capitals
      cash_transactions
      dependants
      employment_income
      irregular_income
      other_incomes
      outgoings
      properties
      state_benefits
      vehicle
    ].freeze

    delegate :version, to: :assessment

    def initialize(spreadsheet_name, spreadsheet, worksheet_name, verbosity_level)
      @spreadsheet_name = spreadsheet_name
      @worksheet_name = worksheet_name
      @worksheet = spreadsheet.sheet(worksheet_name)
      @verbosity_level = verbosity_level
      @rows = @worksheet.to_a
      @cash_transactions = CashTransactionsCollection.new
      @headers = { 'CONTENT_TYPE' => 'application/json', 'Accept' => 'application/json;version=2' }
      @skippable = !@rows[0][1]
    end

    def skippable?
      @skippable
    end

    def description
      "#{@spreadsheet_name} (#{@worksheet_name})"
    end

    def parse_worksheet
      skip_header_rows
      while @rows.any?
        object_type = @rows.first[0]
        __send__("populate_#{object_type.downcase.tr(' ', '_')}")
      end
    end

    def payload_objects
      PAYLOAD_OBJECTS.map { |obj_name| __send__(obj_name) }
    end

    def compare_results(actual_result)
      if version == '3'
        Result.new(@expected_results, actual_result, @verbosity_level).compare
      else
        @expected_results.compare(actual_result, @verbosity_level)
      end
    end

    private

    # def post_payload(obj)
    #   post obj.path, params: obj.payload.to_json, headers: @headers
    # end

    def skip_header_rows
      4.times { @rows.shift }
    end

    def populate_assessment
      @assessment = TestCase::Assessment.new(@worksheet_name, @rows)
    end

    def populate_applicant
      @applicant = TestCase::Applicant.new(@rows.shift(4))
    end

    def populate_dependants
      @dependants = TestCase::DependantCollection.new(@rows)
    end

    def populate_employment_income
      @employment_income = TestCase::EmploymentCollection.new(@rows)
    end

    def populate_other_incomes
      @other_incomes = TestCase::OtherIncomesCollection.new(@rows)
    end

    def populate_state_benefits
      @state_benefits = TestCase::StateBenefitsCollection.new(@rows)
    end

    def populate_irregular_income
      irregular_income_row = @rows.shift
      @irregular_income = IrregularIncome.new(irregular_income_row)
    end

    def populate_outgoings
      @outgoings = TestCase::OutgoingsCollection.new(@rows)
    end

    def populate_cash_transactions_income
      @cash_transactions.add(:income, @rows)
    end

    def populate_cash_transactions_outgoings
      @cash_transactions.add(:outgoings, @rows)
    end

    def populate_capitals
      @capitals = TestCase::CapitalsCollection.new(@rows)
    end

    def populate_properties
      @properties = PropertyCollection.new(@rows)
    end

    def populate_vehicles
      vehicle_rows = @rows.shift(4)
      @vehicle = Vehicle.new(vehicle_rows)
    end

    def populate_expected_results
      @expected_results = version == '4' ? V4::ExpectedResult.new(@rows) : V3::ExpectedResult.new(@rows)
    end

    def populate_earned_income
      # extract the earned income section and remove from the worksheet
      row_index = @rows.index { |r| r.first.present? && r.first != 'earned_income' }
      @rows.shift(row_index)
      nil
    end
  end
end

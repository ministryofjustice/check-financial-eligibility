class ExpectedResultsExtractor
  def initialize(spreadsheet, worksheet_name)
    @worksheet = spreadsheet.sheet(worksheet_name)
    worksheet_rows = @worksheet.to_a
    start_index = worksheet_rows.index { |row| row.first == 'Expected results' }
    @rows = worksheet_rows.slice(start_index + 1, 99)
  end

  def run
    current_object = nil
    expected_results = {}
    @rows.each do |row|
      object, attribute, _unused, expected_result = row
      if object.present?
        expected_results[object.to_sym] = {}
        current_object = object.to_sym
      end
      expected_results[current_object][attribute] = expected_result
    end
    expected_results.deep_symbolize_keys
  end
end

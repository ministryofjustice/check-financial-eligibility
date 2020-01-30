require_relative 'endpoint_data_extractor'
require_relative 'payload_generator'

class DatasetGenerator
  attr_reader :result, :logs

  def initialize(spreadsheet, worksheet_name)
    @worksheet_name = worksheet_name
    @worksheet = spreadsheet.sheet(worksheet_name)
    @rows = @worksheet.to_a
    @headers = extract_header_rows
    @logs = []
    @result = false
    @payload = {}
  end

  def run
    return unless test_active?

    EndpointDataExtractor.new(@rows).run
  end

  private

  def extract_header_rows
    headers = {}
    4.times do
      row = @rows.shift
      headers[row.first] = row[1]
    end
    raise 'Invalid headers' unless headers.keys == ['Test active', 'Test name', 'Notes', 'Object']

    headers
  end

  def test_active?
    @headers['Test active'] == true
  end
end

# :nocov:
class IntegrationTest
  def self.call(*args)
    new(*args).call
  end

  def initialize(worksheet_name)
    @worksheet_name = worksheet_name
  end

  def call
    run_use_case
  end

  private

  attr_reader :worksheet_name

  def run_use_case
    raise "Please set ENV['TEST_SERVICE_URL']" unless ENV['TEST_SERVICE_URL'].present?

    IntegrationTests::UseCaseRunner.call(ENV['TEST_SERVICE_URL'], payload)
  end

  def payload
    IntegrationTests::WorksheetParser.call(worksheet)
  end

  def worksheet
    sheet = spreadsheet.worksheet_by_title(worksheet_name)
    raise "worksheet '#{worksheet_name}' could not be found" unless sheet

    sheet
  end

  def spreadsheet
    raise "Please set ENV['TEST_SPREADSHEET_ID']" unless ENV['TEST_SPREADSHEET_ID'].present?

    IntegrationTests::SpreadsheetRetriever.call(ENV['TEST_SPREADSHEET_ID'])
  end
end
# :nocov:

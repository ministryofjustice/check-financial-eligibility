module IntegrationTests
  class SpreadsheetRetriever
    SCOPE = %w[
      https://www.googleapis.com/auth/drive
      https://spreadsheets.google.com/feeds/
    ].freeze

    def self.call(spreadsheet_key)
      new.call(spreadsheet_key)
    end

    def call(spreadsheet_key)
      check_envs
      session.spreadsheet_by_key(spreadsheet_key)
    end

    private

    def check_envs
      return if ENV['GOOGLE_CLIENT_EMAIL'].present? && ENV['GOOGLE_PRIVATE_KEY'].present?

      raise "Please set ENV['GOOGLE_CLIENT_EMAIL'] and ENV['GOOGLE_PRIVATE_KEY'] in order to retrieve a google spreadsheet"
    end

    def session
      GoogleDrive::Session.new(credentials)
    end

    def credentials
      Google::Auth::ServiceAccountCredentials.make_creds(scope: SCOPE)
    end
  end
end

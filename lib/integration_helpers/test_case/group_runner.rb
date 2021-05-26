module TestCase
  # Class to load the AAA - CFE Integration Test master spreadsheet (downloading it again if
  # the remote version is more up to date), and then open each of the spreadsheets listed in turn
  # and instantiate them as a TestCase::Workbook object, making each available through a .each method
  #
  class GroupRunner
    DATA_DIR = Rails.root.join('tmp/integration_test_data')
    MASTER_SHEET = 'AAA - CFE Integration Test master spreadsheet'.freeze

    def initialize(verbosity_level, refresh)
      @verbosity_level = verbosity_level
      @spreadsheet_names = parse_master_sheet
      @refresh = refresh
      @spreadsheets = {}
      @spreadsheet_names.each { |name| @spreadsheets[name] = load_spreadsheet(name) }
    end

    def each
      @spreadsheets.each do |spreadsheet_name, spreadsheet|
        spreadsheet.sheets.each do |worksheet_name|
          worksheet = TestCase::Worksheet.new(spreadsheet_name, spreadsheet, worksheet_name, @verbosity_level)
          yield(worksheet)
        end
      end
    end

    private

    def parse_master_sheet
      master_spreadsheet = load_spreadsheet(MASTER_SHEET)
      sheet = master_spreadsheet.sheet('Sheets to process')
      sheet.map(&:first)
    end

    def local_spreadsheet_needs_replacing?(local, remote)
      return true unless File.exist?(local)

      return true if @refresh == 'true'

      remote.modified_time > File.mtime(local)
    end

    def local_file_name_for(spreadsheet_title)
      "#{DATA_DIR}/#{spreadsheet_title.downcase.gsub(' - ', '_').tr(' ', '_')}.xlsx"
    end

    def load_spreadsheet(spreadsheet_title)
      FileUtils.mkdir(DATA_DIR) unless File.exist?(DATA_DIR)

      secret_file = StringIO.new(google_secret.to_json)
      session = GoogleDrive::Session.from_service_account_key(secret_file)
      google_sheet = session.spreadsheet_by_title(spreadsheet_title)
      raise "Unable to locate sheet '#{spreadsheet_title}'" if google_sheet.nil?

      local_file_name = local_file_name_for(spreadsheet_title)
      export_to_local_file(local_file_name, google_sheet)
      Roo::Spreadsheet.open(local_file_name)
    end

    def export_to_local_file(local_file_name, google_sheet)
      return unless local_spreadsheet_needs_replacing?(local_file_name, google_sheet)

      puts "Refreshing spreadsheet #{google_sheet.name}"
      google_sheet.export_as_file(local_file_name, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
    end

    # rubocop:disable Metrics/MethodLength
    def google_secret
      {
        type: 'service_account',
        project_id: 'laa-apply-for-legal-aid',
        private_key_id: Rails.configuration.x.google_sheets.private_key_id,
        private_key: Rails.configuration.x.google_sheets.private_key,
        client_email: Rails.configuration.x.google_sheets.client_email,
        client_id: Rails.configuration.x.google_sheets.client_id,
        auth_uri: 'https://accounts.google.com/o/oauth2/auth',
        token_uri: 'https://oauth2.googleapis.com/token',
        auth_provider_x509_cert_url: 'https://www.googleapis.com/oauth2/v1/certs',
        client_x509_cert_url: 'https://www.googleapis.com/robot/v1/metadata/x509/laa-apply-service%40laa-apply-for-legal-aid.iam.gserviceaccount.com'
      }
    end
    # rubocop:enable Metrics/MethodLength
  end
end

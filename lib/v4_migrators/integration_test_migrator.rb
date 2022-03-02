class IntegrationTestMigrator
  DATA_DIR = Rails.root.join("tmp/integration_test_data").freeze
  MASTER_SHEET = "AAA - CFE Integration Test master spreadsheet".freeze
  VALID_SECTION_NAMES = [
    "assessment",
    "applicant",
    "capitals",
    "properties",
    "vehicles",
    "dependants",
    "earned income",
    "outgoings",
    "other_incomes",
    "state_benefits",
    "cash_transactions_income",
    "cash_transactions_outgoings",
    "irregular_income",
  ].freeze

  def initialize
    @master_workbook = Roo::Spreadsheet.open(local_file_name_for(MASTER_SHEET))
    @main_sheet = @master_workbook.sheet("Sheets to process")
    @workbook_names = @main_sheet.map(&:first)
  end

  def run
    @workbook_names.each { |workbook_name| process_workbook(workbook_name) }
  end

private

  def process_workbook(workbook_name)
    book = Roo::Spreadsheet.open(local_file_name_for(workbook_name))
    book.sheets.each { |sheet_name| process_worksheet(book, sheet_name) }
  end

  def process_worksheet(workbook, sheet_name)
    worksheet = workbook.sheet(sheet_name)
    return if version4?(worksheet) || worksheet_inactive?(worksheet)

    @data_hash = {}
    convert_sheet(worksheet, sheet_name)
    output_csv(sheet_name)
  end

  def output_csv(sheet_name)
    csv = @data_hash["headers"]
    csv += convert_assessment_section

    (VALID_SECTION_NAMES - %w[assessment]).each do |section|
      csv += @data_hash[section] if @data_hash.key?(section)
    end

    csv += convert_results_section
    filename = "#{DATA_DIR}/csv/#{sheet_name.upcase}-V4.csv"

    CSV.open(filename, "wb") do |fp|
      csv.each { |row| fp << row }
    end
  end

  def convert_assessment_section
    v4_csv = []
    v4_csv << ["assessment", nil, "submission_date", extract_submission_date]
    v4_csv << [nil, nil, "version", 4]
    v4_csv << [nil, nil, "proceeding_type_codes", "DA004"]
    v4_csv
  end

  def convert_results_section
    v3_results = hasherize_v3_results
    v4_results = []
    v4_results << results_header
    v4_results << ["assessment", "passported", nil, v3_results["assessment_passported"]]
    v4_results << [nil, "assessment_result", nil, v3_results["assessment_assessment_result"]]
    v4_results << [nil, "matter_types", "domestic_abuse", v3_results["assessment_assessment_result"]]
    v4_results << [nil, "proceeding_type: DA004", "assessment_result", v3_results["assessment_assessment_result"]]
    v4_results << [nil, nil, "capital_lower_threshold", v3_results["capital_lower_threshold"]]
    v4_results << [nil, nil, "capital_upper_threshold", v3_results["capital_upper_threshold"]]
    v4_results << [nil, nil, "gross_income_upper_threshold", v3_results["gross_income_upper_threshold"]]
    v4_results << [nil, nil, "disposable_income_lower_threshold", v3_results["disposable_income_summary_lower_threshold"]]
    v4_results << [nil, nil, "disposable_income_upper_threshold", v3_results["disposable_income_summary_upper_threshold"]]
    v4_results << ["gross_income_summary", "monthly_other_income", nil, v3_results["gross_income_summary_monthly_other_income"]]
    v4_results << [nil, "monthly_state_benefits", nil, v3_results["gross_income_summary_monthly_state_benefits"]]
    v4_results << [nil, "monthly_student_loan", nil, nil]
    v4_results << [nil, "total_gross_income", nil, v3_results["gross_income_summary_total_gross_income"]]
    v4_results << ["disposable_income_summary", "childcare", nil, v3_results["disposable_income_summary_childcare"]]
    v4_results << [nil, "dependant_allowance", nil, v3_results["disposable_income_summary_dependant_allowance"]]
    v4_results << [nil, "maintenance", nil, v3_results["disposable_income_summary_maintenance"]]
    v4_results << [nil, "gross_housing_costs", nil, v3_results["disposable_income_summary_gross_housing_costs"]]
    v4_results << [nil, "housing_benefit", nil, v3_results["disposable_income_summary_housing_benefit"]]
    v4_results << [nil, "net_housing_costs", nil, v3_results["disposable_income_summary_net_housing_costs"]]
    v4_results << [nil, "total_outgoings_and_allowances", nil, v3_results["disposable_income_summary_total_outgoings_and_allowances"]]
    v4_results << [nil, "total_disposable_income", nil, v3_results["disposable_income_summary_total_disposable_income"]]
    v4_results << [nil, "income_contribution", nil, nil]
    v4_results << ["capital", "total_liquid", nil, v3_results["capital_total_liquid"]]
    v4_results << [nil, "total_non_liquid", nil, v3_results["capital_total_non_liquid"]]
    v4_results << [nil, "total_vehicle", nil, v3_results["capital_total_vehicle"]]
    v4_results << [nil, "total_mortgage_allowance", nil, v3_results["capital_total_mortgage_allowance"]]
    v4_results << [nil, "total_capital", nil, v3_results["capital_total_capital"]]
    v4_results << [nil, "pensioner_capital_disregard", nil, v3_results["capital_pensioner_capital_disregard"]]
    v4_results << [nil, "assessed_capital", nil, v3_results["capital_assessed_capital"]]
    v4_results << [nil, "capital_contribution", nil, v3_results["capital_capital_contribution"]]
    v4_results
  end

  def hasherize_v3_results
    v3_results = {}
    col1 = nil
    @data_hash["results"].each do |row|
      col1 = row.first if row.first.present?
      col2 = row[1]
      v3_results["#{col1}_#{col2}"] = row[3]
    end
    v3_results
  end

  def extract_submission_date
    rows = @data_hash["assessment"]
    raise "Unable to find submission date" unless rows.first[2] == "submission_date"

    rows.first[3].strftime("%F")
  end

  def convert_sheet(worksheet, sheet_name)
    rows = sheet_to_array(worksheet)
    @data_hash["headers"] = rows.slice!(0, 4)

    while rows.any?
      section_name = rows.first.first
      if section_name.in? VALID_SECTION_NAMES
        store_section(section_name, rows)
      elsif section_name == "Expected results"
        @data_hash["results"] = rows
        rows = []
      else
        raise "Unexpected item #{rows.first} in the bagging area (#{sheet_name})"
      end
    end
  end

  def store_section(section_name, rows)
    index = rows.index { |r| r.first != section_name && r.first.present? }
    @data_hash[section_name] = rows.slice!(0, index)
  end

  def local_file_name_for(spreadsheet_title)
    "#{DATA_DIR}/#{spreadsheet_title.downcase.gsub(' - ', '_').tr(' ', '_')}.xlsx"
  end

  def version4?(worksheet)
    row = worksheet.row(6)
    row[2] == "version" && row[3] == 4
  end

  def worksheet_inactive?(worksheet)
    row = worksheet.row(1)
    row[0] == "Test active" && row[1] == false
  end

  def sheet_to_array(worksheet)
    rows = []
    worksheet.each { |row| rows << row }
    rows
  end

  def results_header
    ["Expected results"]
  end
end

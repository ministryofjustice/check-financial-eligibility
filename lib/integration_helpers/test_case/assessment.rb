module TestCase
  class Assessment
    attr_reader :version

    def initialize(worksheet_name, rows)
      @worksheet_name = worksheet_name
      populate_assessment(rows)
    end

    def url
      Rails.application.routes.url_helpers.assessments_path
    end

    def payload
      @version = "3" if @version.nil?
      @version == "3" ? version_3_payload : version_4_payload
    end

    def version_3_payload
      {
        client_reference_id: @worksheet_name,
        submission_date: @submission_date,
        matter_proceeding_type: @matter_proceeding_type,
      }
    end

    def version_4_payload
      {
        client_reference_id: @worksheet_name,
        submission_date: @submission_date,
        proceeding_types: {
          ccms_codes: @proceeding_type_codes,
        },
        assessment_type: @assessment_type,
      }
    end

  private

    def populate_assessment(rows)
      assessment_rows = extract_assessment_rows(rows)
      assessment_rows.each { |row| populate_attribute(row) }
    end

    def extract_assessment_rows(rows)
      row_index = rows.index { |r| r.first.present? && r.first != "assessment" }
      rows.shift(row_index)
    end

    def populate_attribute(row)
      case row[2]
      when "submission_date"
        @submission_date = row[3]
      when "matter_proceeding_type"
        @matter_proceeding_type = row[3]
      when "version"
        @version = row[3].to_i.to_s
      when "proceeding_type_codes"
        @proceeding_type_codes = row[3].split(";")
      when "assessment_type"
        @assessment_type = row[3]
      end
    end
  end
end

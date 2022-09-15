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
      version_5_payload
    end

    def version_5_payload
      {
        client_reference_id: @worksheet_name,
        submission_date: @submission_date,
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
      when "version"
        @version = row[3].to_i.to_s
      end
    end
  end
end

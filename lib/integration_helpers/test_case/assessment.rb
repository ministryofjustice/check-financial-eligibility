module TestCase
  class Assessment
    def initialize(worksheet_name, rows)
      @worksheet_name = worksheet_name
      @submission_date = rows.first[3]
      @matter_proceeding_type = rows.last[3]
    end

    def url
      Rails.application.routes.url_helpers.assessments_path
    end

    def payload
      {
        client_reference_id: @worksheet_name,
        submission_date: @submission_date,
        matter_proceeding_type: @matter_proceeding_type
      }
    end
  end
end

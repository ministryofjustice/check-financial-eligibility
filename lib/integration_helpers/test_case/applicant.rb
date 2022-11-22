module TestCase
  class Applicant
    def initialize(rows)
      @rows = rows.reject { |row| row[2].nil? }
    end

    def url_method
      :assessment_applicant_path
    end

    def payload
      {
        applicant: { **attributes_from_rows },
      }
    end

    def empty?
      false
    end

  private

    def attributes_from_rows
      @rows.each_with_object({}) do |row, h|
        h[row[2].to_sym] = row[3]
      end
    end
  end
end

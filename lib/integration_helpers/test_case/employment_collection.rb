module TestCase
  class EmploymentCollection
    def initialize(rows)
      @employment_earnings = {}
      populate_employments(rows)
    end

    def url_method
      :assessment_employments_path
    end

    def payload
      {
        employment_income: employment_payload,
      }
    end

    def empty?
      @employment_earnings.empty?
    end

  private

    def employment_payload
      payload = []
      @employment_earnings.each do |job_name, job_hash|
        payload << job_hash_to_payload(job_name, job_hash)
      end
      payload
    end

    def job_hash_to_payload(job_name, job_hash)
      {
        name: job_name,
        client_id: job_hash[:client_id],
        payments: job_hash[:payments],
      }
    end

    def populate_employments(rows)
      employment_rows = extract_employment_rows(rows)

      while employment_rows.any?
        payment_data = employment_rows.shift(6)
        job_name_and_job_id = payment_data.first[1] if payment_data.first[1].present?
        raise "No job name specified in column B for employment data" if job_name_and_job_id.blank?

        job_name, job_id = job_name_and_job_id.split(":")
        add_employment_earnings(job_name, payment_data, job_id)

      end
    end

    def extract_employment_rows(rows)
      row_index = rows.index { |r| r.first.present? && r.first != "employment_income" }
      rows.shift(row_index)
    end

    def add_employment_earnings(job_name, data_rows, job_id)
      @employment_earnings[job_name] = { client_id: job_id, payments: [] } unless @employment_earnings.key?(job_name)

      @employment_earnings[job_name][:payments] << employment_payment(data_rows, job_id)
    end

    def employment_payment(data_rows, job_id)
      payment_hash = { client_id: job_id }
      data_rows.each do |row|
        transform_row_to_hash(row, payment_hash)
      end
      payment_hash[:net_employment_income] = calculate_net(payment_hash)
      payment_hash
    end

    def transform_row_to_hash(row, payment_hash)
      case row[2].strip
      when "client_id"
        payment_hash[:client_id] = row[3]
      when "date"
        payment_hash[:date] = row[3].strftime("%F")
      when "gross pay"
        payment_hash[:gross] = row[3]
      when "benefits in kind"
        payment_hash[:benefits_in_kind] = row[3]
      when "tax"
        payment_hash[:tax] = row[3]
      when "national insurance"
        payment_hash[:national_insurance] = row[3]
      else
        raise "Unexpected key '#{row[2]}' in column C of employment data"
      end
    end

    def calculate_net(payment_hash)
      (payment_hash[:gross] + payment_hash[:benefits_in_kind] + payment_hash[:tax] + payment_hash[:national_insurance]).round(2)
    end
  end
end

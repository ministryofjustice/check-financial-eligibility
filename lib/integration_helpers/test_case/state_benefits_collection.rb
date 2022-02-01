module TestCase
  class StateBenefitsCollection
    def initialize(rows)
      @benefits = Hash.new { |hash, key| hash[key] = [] }
      populate_benefits(rows)
    end

    def url_method
      :assessment_state_benefits_path
    end

    def payload
      {
        state_benefits: @benefits.keys.map { |benefit_type| benefit_type_payload(benefit_type) },
      }
    end

    def empty?
      @benefits.empty?
    end

  private

    def benefit_type_payload(benefit_type)
      {
        name: benefit_type,
        payments: @benefits[benefit_type].map(&:payload),
      }
    end

    def populate_benefits(rows)
      benefits_rows = extract_benefits_rows(rows)

      while benefits_rows.any?
        benefits_data = benefits_rows.shift(3)
        next if benefits_data.first[3].nil?

        benefits_type = benefits_data.first[1] if benefits_data.first[1].present?
        add_benefits(benefits_type, benefits_data)

      end
    end

    def extract_benefits_rows(rows)
      row_index = rows.index { |r| r.first.present? && r.first != "state_benefits" }
      rows.shift(row_index)
    end

    def add_benefits(benefits_type, benefits_data)
      payment = Payment.new(date: benefits_data[0][3], client_id: benefits_data[1][3], amount: benefits_data[2][3])
      @benefits[benefits_type] << payment
    end
  end
end

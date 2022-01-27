module TestCase
  class OtherIncomesCollection
    def initialize(rows)
      @other_incomes = Hash.new { |hash, key| hash[key] = [] }
      populate_other_incomes(rows)
    end

    def url_method
      :assessment_other_incomes_path
    end

    def payload
      {
        other_incomes: @other_incomes.keys.map { |source| source_payload(source) }
      }
    end

    def empty?
      @other_incomes.empty?
    end

  private

    def source_payload(payment_source)
      {
        source: payment_source,
        payments: @other_incomes[payment_source].map(&:payload)
      }
    end

    def populate_other_incomes(rows)
      other_income_rows = extract_other_income_rows(rows)

      while other_income_rows.any?
        other_income_data = other_income_rows.shift(3)
        other_income_type = other_income_data.first[1] if other_income_data.first[1].present?
        add_other_income(other_income_type, other_income_data)

      end
    end

    def extract_other_income_rows(rows)
      row_index = rows.index { |r| r.first.present? && r.first != 'other_incomes' }
      rows.shift(row_index)
    end

    def add_other_income(other_income_type, other_income_data)
      payment = Payment.new(date: other_income_data[0][3], client_id: other_income_data[1][3], amount: other_income_data[2][3])
      @other_incomes[other_income_type] << payment unless payment.all_nil?
    end
  end
end

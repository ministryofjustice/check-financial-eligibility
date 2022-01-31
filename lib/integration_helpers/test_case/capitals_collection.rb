module TestCase
  class CapitalsCollection
    def initialize(rows)
      @capital = Hash.new { |hash, key| hash[key] = [] }
      populate_capitals(rows)
    end

    def url_method
      :assessment_capitals_path
    end

    def payload
      {
        bank_accounts: capital_payload(:bank_accounts),
        non_liquid_capital: capital_payload(:non_liquid_capital)
      }
    end

    def empty?
      false
    end

  private

    def capital_payload(type)
      @capital[type].map(&:payload)
    end

    def non_liquid_capital_payload
      @capital["non_liquid_capital"].map(&:payload)
    end

    def populate_capitals(rows)
      capital_rows = extract_capital_rows(rows)

      while capital_rows.any?
        capital_data = capital_rows.shift(2)
        capital_type = capital_data.first[1].to_sym if capital_data.first[1].present?
        add_capital(capital_type, capital_data)

      end
    end

    def extract_capital_rows(rows)
      row_index = rows.index { |r| r.first.present? && r.first != "capitals" }
      rows.shift(row_index)
    end

    def add_capital(capital_type, capital_data)
      asset = Asset.new(description: capital_data.first[3], amount: capital_data.last[3])
      @capital[capital_type] << asset unless asset.all_nil?
    end
  end
end

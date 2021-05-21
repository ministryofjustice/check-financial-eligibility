module TestCase
  class CashTransactionsCollection
    def initialize
      @collection = {
        income: hash_with_array_as_default,
        outgoings: hash_with_array_as_default
      }
    end

    def add(in_out, rows)
      populate_cash_transactions(in_out.to_sym, rows)
    end

    def url_method
      :assessment_cash_transactions_path
    end

    def payload
      {
        income: @collection[:income].keys.map { |category| payload_for_category(:income, category) },
        outgoings: @collection[:outgoings].keys.map { |category| payload_for_category(:outgoings, category) }
      }
    end

    def empty?
      @collection[:income].empty? && @collection[:outgoings].empty?
    end

    private

    def payload_for_category(in_out, category)
      {
        category: category,
        payments: @collection[in_out][category].map(&:payload)
      }
    end

    def hash_with_array_as_default
      Hash.new { |hash, key| hash[key] = [] }
    end

    def populate_cash_transactions(in_out, rows)
      cash_transactions_rows = extract_cash_transactions_rows(in_out, rows)

      while cash_transactions_rows.any?
        cash_transactions_data = cash_transactions_rows.shift(3)
        cash_transactions_type = cash_transactions_data.first[1] if cash_transactions_data.first[1].present?
        add_cash_transactions(in_out, cash_transactions_type, cash_transactions_data)

      end
    end

    def extract_cash_transactions_rows(in_out, rows)
      row_index = rows.index { |r| r.first.present? && r.first != "cash_transactions_#{in_out}" }
      rows.shift(row_index)
    end

    def add_cash_transactions(in_out, cash_transactions_type, cash_transactions_data)
      payment = Payment.new(date: cash_transactions_data[0][3], client_id: cash_transactions_data[1][3], amount: cash_transactions_data[2][3])
      return if payment.all_nil?

      @collection[in_out][cash_transactions_type] << payment unless payment.all_nil?
    end
  end
end

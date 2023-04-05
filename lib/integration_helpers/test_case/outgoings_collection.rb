module TestCase
  class OutgoingsCollection
    def initialize(rows)
      @outgoings = Hash.new { |hash, key| hash[key] = [] }
      populate_outgoings(rows)
    end

    def url_method
      :assessment_outgoings_path
    end

    def payload
      {
        outgoings: @outgoings.keys.map { |type| type_payload(type) },
      }
    end

    def type_payload(type)
      {
        name: type,
        payments: @outgoings[type].map { |payment| payment.payload(date_field: :payment_date) },
      }
    end

    def empty?
      @outgoings.empty?
    end

  private

    def populate_outgoings(rows)
      outgoings_rows = extract_outgoings_rows(rows)
      outgoings_type = outgoings_rows.first[1]

      while outgoings_rows.any?
        outgoings_type = outgoings_rows.first[1] if outgoings_rows.first[1].present?
        number_of_rows_to_shift = outgoings_type == "rent_or_mortgage" ? 4 : 3
        outgoings_data = outgoings_rows.shift(number_of_rows_to_shift)

        add_outgoings(outgoings_type, outgoings_data)
      end
    end

    def extract_outgoings_rows(rows)
      row_index = rows.index { |r| r.first.present? && r.first != "outgoings" }
      rows.shift(row_index)
    end

    def add_outgoings(outgoings_type, outgoings_data)
      payment = outgoings_type == "rent_or_mortgage" ? payment_with_meta(outgoings_data) : payment_without_meta(outgoings_data)
      @outgoings[outgoings_type] << payment unless payment.all_nil?
    end

    def payment_with_meta(outgoings_data)
      Payment.new date: outgoings_field(outgoings_data, "payment_date"),
                  client_id: outgoings_field(outgoings_data, "client_id"),
                  amount: outgoings_field(outgoings_data, "amount"),
                  housing_cost_type: outgoings_field(outgoings_data, "housing_cost_type")
    end

    def payment_without_meta(outgoings_data)
      Payment.new date: outgoings_field(outgoings_data, "payment_date"),
                  client_id: outgoings_field(outgoings_data, "client_id"),
                  amount: outgoings_field(outgoings_data, "amount")
    end

    def outgoings_field(outgoings_data, field_name)
      outgoings_data.detect { |d| d[2] == field_name }[3]
    end
  end
end

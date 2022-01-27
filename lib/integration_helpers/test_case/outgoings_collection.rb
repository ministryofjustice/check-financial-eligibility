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
        outgoings: @outgoings.keys.map { |type| type_payload(type) }
      }
    end

    def type_payload(type)
      {
        name: type,
        payments: @outgoings[type].map { |payment| payment.payload(date_field: :payment_date) }
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
        number_of_rows_to_shift = outgoings_type == 'rent_or_mortgage' ? 4 : 3
        outgoings_data = outgoings_rows.shift(number_of_rows_to_shift)

        add_outgoings(outgoings_type, outgoings_data)
      end
    end

    def extract_outgoings_rows(rows)
      row_index = rows.index { |r| r.first.present? && r.first != 'outgoings' }
      rows.shift(row_index)
    end

    def add_outgoings(outgoings_type, outgoings_data)
      payment = outgoings_type == 'rent_or_mortgage' ? payment_with_meta(outgoings_data) : payment_without_meta(outgoings_data)
      @outgoings[outgoings_type] << payment unless payment.all_nil?
    end

    def payment_with_meta(outgoings_data)
      Payment.new(date: outgoings_data[0][3],
                  client_id: outgoings_data[2][3],
                  amount: outgoings_data[3][3],
                  meta: outgoings_data[1][3])
    rescue StandardError => err
      puts err.class
      puts err.message
      pp outgoings_data
    end

    def payment_without_meta(outgoings_data)
      Payment.new(date: outgoings_data[0][3],
                  client_id: outgoings_data[1][3],
                  amount: outgoings_data[2][3])
    end
  end
end

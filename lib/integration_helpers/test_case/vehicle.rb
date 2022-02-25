module TestCase
  class Vehicle
    def initialize(rows)
      @value = rows.first[3]
      @date_of_purchase = rows[1][3]
      @in_regular_use = rows[2][3]
      @loan_amount_outstanding = rows[3][3]
    end

    def url_method
      :assessment_vehicles_path
    end

    def payload
      {
        vehicles: [
          {
            value: @value,
            date_of_purchase: @date_of_purchase,
            loan_amount_outstanding: @loan_amount_outstanding,
            in_regular_use: @in_regular_use,
          },
        ],
      }
    end

    def empty?
      @value.nil?
    end
  end
end

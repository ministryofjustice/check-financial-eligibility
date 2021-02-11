module TestCase
  class IrregularIncome
    def initialize(row)
      @description = row[1]
      @amount = row[3]
      @frequency = 'annual'
    end

    def url_method
      :assessment_irregular_incomes_path
    end

    def payload
      {
        payments: [
          {
            income_type: @description,
            frequency: @frequency,
            amount: @amount
          }
        ]
      }
    end
  end
end

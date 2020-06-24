class IrregularIncomePayloadGenerator
  def initialize(rows)
    raise 'Too many irregular income values' if rows.size != 1

    @row = rows.first
  end

  def run
    _object, income_type, _label, amount = @row

    {
      payments: [
        {
          income_type: income_type,
          frequency: 'annual',
          amount: amount
        }
      ]
    }
  end
end

module Calculators
  class VehicleAgeCalculator
    def initialize(purchase_date, calculation_date)
      @purchase_date = purchase_date
      @calculation_date = calculation_date
    end

    def in_months
      months = ((@calculation_date.year * 12) + @calculation_date.month) - ((@purchase_date.year * 12) + @purchase_date.month)
      months += 1 if @purchase_date.day < @calculation_date.day
      months
    end
  end
end

class PersonCapitalSubtotals
  def initialize(total_vehicle: nil)
    @total_vehicle = total_vehicle
  end

  attr_reader :total_vehicle
end

module Assessors
  class VehicleAssessor
    class << self
      def call(vehicles)
        vehicles.each(&:assess!)
        vehicles.sum(&:assessed_value)
      end
    end
  end
end

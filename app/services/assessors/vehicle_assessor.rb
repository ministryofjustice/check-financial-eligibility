module Assessors
  class VehicleAssessor < BaseWorkflowService
    def call
      vehicles.each(&:assess!)
      vehicles.sum(&:assessed_value)
    end
  end
end

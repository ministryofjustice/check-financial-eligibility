class VehiclesController < ApplicationController
  def create
    result = vehicle_creation_service.call
    if result.success
      render json: result.to_h
    else
      render json: result.to_h, status: 422
    end
  end

  private

  def vehicle_creation_service
    VehicleCreationService.new(request.raw_post)
  end
end

class VehiclesController < ApplicationController
  def create
    result = VehicleCreationService.call(request.raw_post)
    if result.success
      render json: result.to_h
    else
      render json: result.to_h, status: 422
    end
  end
end

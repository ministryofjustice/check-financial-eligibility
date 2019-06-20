class CapitalsController < ApplicationController
  def create
    if creation_service_result.success?
      render json: {
        success: true,
        objects: creation_service_result.capital,
        errors: []
      }
    else
      render json: {
        success: false,
        objects: nil,
        errors: creation_service_result.errors
      }, status: 422
    end
  end

  private

  def creation_service_result
    @creation_service_result ||= CapitalsCreationService.call(request.raw_post)
  end
end

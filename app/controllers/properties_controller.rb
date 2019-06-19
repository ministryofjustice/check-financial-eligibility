class PropertiesController < ApplicationController
  def create
    result = PropertiesCreationService.call(request.raw_post)
    render json: result.to_h, status: result.success ? 200 : 422
  end
end

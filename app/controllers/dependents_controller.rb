class DependentsController < ApplicationController
  def create
    service = DependentCreationService.new(request.raw_post)
    render json: service.response_payload, status: service.http_status
  end
end

class IncomesController < ApplicationController
  def create
    service = IncomeCreationService.new(request.raw_post)
    render json: service.response_payload, status: service.http_status
  end
end

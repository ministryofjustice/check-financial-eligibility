class AssessmentsController < ApplicationController
  def create
    service = AssessmentCreationService.new(request.remote_ip, request.raw_post)
    render json: service.response_payload, status: service.http_status
  end
end

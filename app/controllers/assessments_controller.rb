class AssessmentsController < ApplicationController
  def create
    service = AssessmentService.new(request.remote_ip, request.raw_post)
    service.call
    render json: service.response_payload, status: service.http_status
  end
end

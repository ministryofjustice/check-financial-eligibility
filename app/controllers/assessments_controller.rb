class AssessmentsController < ApplicationController
  def create
    if assessment_creation.success?
      render json: success_response
    else
      render json: error_response, status: 422
    end
  end

  private

  def success_response
    {
      status: :ok,
      assessment_id: assessment.id
    }
  end

  def error_response
    {
      status: :error,
      errors: assessment_creation.errors
    }
  end

  def assessment
    assessment_creation.assessment
  end

  def assessment_creation
    @assessment_creation ||= AssessmentCreationService.new(request.remote_ip, request.raw_post)
  end
end

class DependentsController < ApplicationController
  def create
    if dependent_creation_service.success?
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
      errors: dependent_creation_service.errors
    }
  end

  def assessment
    dependent_creation_service.assessment
  end

  def dependent_creation_service
    @dependent_creation_service ||= DependentsCreationService.new(request.raw_post)
  end
end

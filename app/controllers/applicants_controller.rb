class ApplicantsController < ApplicationController
  def create
    if applicant_creation_service.success?
      render json: success_response
    else
      render json: error_response, status: 422
    end
  end

  private

  def applicant_creation_service
    @applicant_creation_service ||= ApplicantCreationService.new(request.raw_post)
  end

  def success_response
    {
      status: :ok,
      assessment_id: applicant_creation_service.assessment.id
    }
  end

  def error_response
    {
      status: :error,
      errors: applicant_creation_service.errors
    }
  end
end

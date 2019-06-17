class IncomesController < ApplicationController
  def create
    if income_creation_service.success?
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
      errors: income_creation_service.errors
    }
  end

  def assessment
    income_creation_service.assessment
  end

  def income_creation_service
    @income_creation_service ||= IncomeCreationService.new(request.raw_post)
  end
end

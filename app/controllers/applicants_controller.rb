class ApplicantsController < ApplicationController
  def create
    if creation_service.success?
      render_success
    else
      render_unprocessable(creation_service.errors)
    end
  end

private

  def creation_service
    @creation_service ||= Creators::ApplicantCreator.call(
      assessment_id: params[:assessment_id],
      applicant_params:,
    )
  end

  def applicant_params
    JSON.parse(request.raw_post, symbolize_names: true)
  end
end

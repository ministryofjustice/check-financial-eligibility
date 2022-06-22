class ExplicitRemarksController < ApplicationController
  def create
    creation_service
    if creation_service.success?
      render_success
    else
      render_unprocessable(creation_service.errors)
    end
  end

private

  def creation_service
    @creation_service ||= Creators::ExplicitRemarksCreator.call(
      assessment_id: params[:assessment_id],
      explicit_remarks_params: request.raw_post,
    )
  end
end

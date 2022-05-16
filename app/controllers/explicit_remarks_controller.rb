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
      remarks_attributes: params[:explicit_remarks],
    )
  end
end

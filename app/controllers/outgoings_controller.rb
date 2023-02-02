class OutgoingsController < ApplicationController
  def create
    if outgoing_creation_service.success?
      render_success
    else
      render_unprocessable(outgoing_creation_service.errors)
    end
  end

private

  def outgoing_creation_service
    @outgoing_creation_service ||= Creators::OutgoingsCreator.call(
      outgoings_params:,
      assessment_id: params[:assessment_id],
    )
  end

  def outgoings_params
    JSON.parse(request.raw_post, symbolize_names: true)
  end
end

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
      outgoings: input[:outgoings],
      assessment_id: params[:assessment_id],
    )
  end

  def input
    @input ||= JSON.parse(request.raw_post, symbolize_names: true)
  end
end

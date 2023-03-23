class OutgoingsController < ApplicationController
  before_action :load_assessment

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
      assessment: @assessment,
    )
  end

  def outgoings_params
    JSON.parse(request.raw_post, symbolize_names: true)
  end
end

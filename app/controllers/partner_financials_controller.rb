class PartnerFinancialsController < ApplicationController
  def create
    if creation_service.success?
      render_success
    else
      render_unprocessable(creation_service.errors)
    end
  end

private

  def creation_service
    @creation_service ||= Creators::PartnerFinancialsCreator.call(
      assessment_id: params[:assessment_id],
      partner_financials_params:,
    )
  end

  def partner_financials_params
    JSON.parse(request.raw_post, symbolize_names: true)
  end
end

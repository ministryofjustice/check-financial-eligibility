class CapitalsController < ApplicationController
  def create
    if creation_service.success?
      render_success
    else
      render_unprocessable(creation_service.errors)
    end
  end

private

  def creation_service
    @creation_service ||= Creators::CapitalsCreator.call(
      assessment_id: params[:assessment_id],
      bank_accounts_attributes: input[:bank_accounts],
      non_liquid_capitals_attributes: input[:non_liquid_capital],
    )
  end

  def input
    @input ||= JSON.parse(request.raw_post, symbolize_names: true)
  end
end

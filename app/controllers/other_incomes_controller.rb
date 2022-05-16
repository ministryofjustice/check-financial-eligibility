class OtherIncomesController < ApplicationController
  def create
    if creation_service.success?
      render_success
    else
      render_unprocessable(creation_service.errors)
    end
  end

private

  def creation_service
    @creation_service ||= Creators::OtherIncomesCreator.call(
      assessment_id: params[:assessment_id],
      other_incomes: other_income_params,
    )
  end

  def other_income_params
    JSON.parse(request.raw_post, symbolize_names: true)
  end
end

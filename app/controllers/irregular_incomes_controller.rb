class IrregularIncomesController < ApplicationController
  before_action :load_assessment

  def create
    if creation_service.success?
      render_success
    else
      render_unprocessable(creation_service.errors)
    end
  end

private

  def creation_service
    @creation_service ||= Creators::IrregularIncomeCreator.call(
      irregular_income_params:,
      gross_income_summary: @assessment.gross_income_summary,
    )
  end

  def irregular_income_params
    JSON.parse(request.raw_post, symbolize_names: true)
  end
end

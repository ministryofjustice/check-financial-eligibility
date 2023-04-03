class IrregularIncomesController < ApplicationController
  before_action :load_assessment

  def create
    json_validator = JsonValidator.new("irregular_incomes", irregular_income_params)
    if json_validator.valid?
      Creators::IrregularIncomeCreator.call(
        irregular_income_params:,
        gross_income_summary: @assessment.gross_income_summary,
      )
      render_success
    else
      render_unprocessable(json_validator.errors)
    end
  end

private

  def irregular_income_params
    JSON.parse(request.raw_post, symbolize_names: true)
  end
end

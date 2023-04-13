class IrregularIncomesController < CreationController
  before_action :load_assessment

  def create
    json_validate_and_render "irregular_incomes", irregular_income_params, lambda {
      Creators::IrregularIncomeCreator.call(
        irregular_income_params:,
        gross_income_summary: @assessment.gross_income_summary,
      )
    }
  end

private

  def irregular_income_params
    JSON.parse(request.raw_post, symbolize_names: true)
  end
end

class StateBenefitsController < CreationController
  before_action :load_assessment

  def create
    json_validate_and_render "state_benefits", state_benefits_params, lambda {
      Creators::StateBenefitsCreator.call(
        gross_income_summary: @assessment.gross_income_summary,
        state_benefits_params:,
      )
    }
  end

private

  def state_benefits_params
    JSON.parse(request.raw_post, symbolize_names: true)
  end
end

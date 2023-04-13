class CapitalsController < CreationController
  before_action :load_assessment

  def create
    swagger_validate_and_render("capitals", capital_params, lambda {
      Creators::CapitalsCreator.call(
        capital_params:,
        capital_summary: @assessment.capital_summary,
      )
    })
  end

private

  def capital_params
    JSON.parse(request.raw_post, symbolize_names: true)
  end
end

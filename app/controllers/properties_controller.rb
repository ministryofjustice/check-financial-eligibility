class PropertiesController < CreationController
  before_action :load_assessment

  def create
    json_validate_and_render("properties", properties_params, lambda {
      Creators::PropertiesCreator.call(
        capital_summary: @assessment.capital_summary,
        properties_params:,
      )
    })
  end

private

  def properties_params
    JSON.parse(request.raw_post, symbolize_names: true)
  end
end

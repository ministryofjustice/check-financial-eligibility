class CapitalsController < ApplicationController
  before_action :load_assessment

  def create
    json_validator = JsonSwaggerValidator.new("capitals", capital_params)

    if json_validator.valid?
      create_capitals
      render_success
    else
      render_unprocessable(json_validator.errors)
    end
  end

private

  def create_capitals
    Creators::CapitalsCreator.call(
      capital_params:,
      capital_summary: @assessment.capital_summary,
    )
  end

  def capital_params
    JSON.parse(request.raw_post, symbolize_names: true)
  end
end

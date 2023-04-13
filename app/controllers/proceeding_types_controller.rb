class ProceedingTypesController < CreationController
  before_action :load_assessment

  def create
    json_validate_and_render("proceeding_types", proceeding_types_params, lambda {
      Creators::ProceedingTypesCreator.call(
        assessment: @assessment,
        proceeding_types_params:,
      )
    })
  end

private

  def proceeding_types_params
    JSON.parse(request.raw_post, symbolize_names: true)
  end
end

class DependantsController < CreationController
  before_action :load_assessment

  def create
    json_validate_and_render("dependants", dependants_params, lambda {
      Creators::DependantsCreator.call(
        dependants: @assessment.dependants,
        dependants_params:,
      )
    })
  end

private

  def dependants_params
    JSON.parse(request.raw_post, symbolize_names: true)
  end
end

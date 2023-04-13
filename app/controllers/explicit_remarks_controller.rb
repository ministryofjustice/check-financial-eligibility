class ExplicitRemarksController < CreationController
  before_action :load_assessment

  def create
    json_validate_and_render("explicit_remarks", explicit_remarks_params, lambda {
      Creators::ExplicitRemarksCreator.call(
        assessment: @assessment,
        explicit_remarks_params:,
      )
    })
  end

private

  def explicit_remarks_params
    JSON.parse(request.raw_post, symbolize_names: true)
  end
end

class ApplicantsController < CreationController
  before_action :load_assessment

  def create
    json_validate_and_render("applicant_v5", applicant_params, lambda {
      Creators::ApplicantCreator.call(
        assessment: @assessment,
        applicant_params:,
      )
    })
  end

private

  def applicant_params
    JSON.parse(request.raw_post, symbolize_names: true)
  end
end

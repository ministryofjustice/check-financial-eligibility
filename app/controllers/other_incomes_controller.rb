class OtherIncomesController < CreationController
  before_action :load_assessment

  def create
    json_validate_and_render("other_incomes", other_incomes_params, lambda {
      Creators::OtherIncomesCreator.call(
        assessment: @assessment,
        other_incomes_params:,
      )
    })
  end

private

  def other_incomes_params
    JSON.parse(request.raw_post, symbolize_names: true)
  end
end

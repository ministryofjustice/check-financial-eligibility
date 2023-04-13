class PartnerFinancialsController < CreationController
  before_action :load_assessment

  def create
    swagger_validate_and_render "partner_financials", partner_financials_params, lambda {
      Creators::PartnerFinancialsCreator.call(
        assessment: @assessment,
        partner_financials_params:,
      )
    }
  end

private

  def partner_financials_params
    JSON.parse(request.raw_post, symbolize_names: true)
  end
end

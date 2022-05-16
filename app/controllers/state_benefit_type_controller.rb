class StateBenefitTypeController < ApplicationController
  def index
    render json: StateBenefitType.as_cfe_json
  end
end

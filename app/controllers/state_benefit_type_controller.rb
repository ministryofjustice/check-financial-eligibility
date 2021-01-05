class StateBenefitTypeController < ApplicationController
  resource_description do
    short 'Return state benefit types'
    formats ['json'] # rubocop:disable Layout/SpaceBeforeBrackets
    description <<-END_OF_TEXT
    == Description
      Returns all state benefit types' name, label and DWP code.
    END_OF_TEXT
  end

  api :GET, 'state_benefit_type', 'List of state benefit types'
  formats ['json'] # rubocop:disable Layout/SpaceBeforeBrackets

  def index
    render json: StateBenefitType.as_cfe_json
  end
end

class StateBenefitTypeController < ApplicationController
  resource_description do
    short 'Return state benefit types'
    formats ['json']
    description <<-END_OF_TEXT
    == Description
      Returns all state benefit types' name, label and dwpcode.
    END_OF_TEXT
  end

  api :GET, 'state_benefit_type', 'List of state benefit types'
  formats ['json']

  def index
    render json: StateBenefitType.as_cfe_json
  end
end

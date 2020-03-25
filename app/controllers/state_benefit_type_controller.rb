class StateBenefitTypeController < ApplicationController
  resource_description do
    short 'Return state benefit types'
    formats ['json']
    description <<-END_OF_TEXT
    == Description
      Returns all state benefit types.
    END_OF_TEXT
  end

  api :GET, 'state_benefit_type', 'List of state benefit types'
  formats ['json']
  param :state_benefit_type, Array, desc: 'Collection of state benefit types' do
    param :name, String, required: false, desc: 'The state benefit type name'
    param :label, String, required: false, desc: 'The state benefit type label'
    param :dwp_code, String, required: false, desc: 'The state benefit type dwpcode'
  end

  def index
    column_names = %w[name label dwp_code]
    render json: StateBenefitType.pluck(column_names).map { |n, l, d| { name: n, label: l, dwp_code: d } }
  end
end

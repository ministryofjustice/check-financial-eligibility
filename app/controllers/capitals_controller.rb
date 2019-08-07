class CapitalsController < ApplicationController
  api :POST, 'assessments/:assessment_id/capitals', 'Create capital declarations'
  formats ['json']
  param :assessment_id, :uuid, required: true
  param :liquid_capital, Hash, desc: 'Defines liquid capital assets' do
    param :bank_accounts, Array, required: true, desc: 'Collection of bank accounts' do
      param :name, String, required: true, desc: 'An identifying name for this bank account'
      param :lowest_balance, :currency, required: true, desc: 'The lowest balance on this bank account during the calculation period'
    end
  end

  param :non_liquid_capital, Array, desc: 'Collection of non-liquid capital assets' do
    param :description, String, required: true, desc: 'An description of this non-liquid asset'
    param :value, :currency, required: true, desc: 'Estimated value of this non-liquid asset'
  end

  returns code: :ok, desc: 'Successful response' do
    property :objects, array_of: Object
    property :success, ['true'], desc: 'Success flag shows true'
  end
  returns code: :unprocessable_entity do
    property :errors, array_of: String, desc: 'Description of why object invalid'
    property :success, ['false'], desc: 'Success flag shows false'
  end

  def create
    if creation_service.success?
      render_success objects: creation_service.capital
    else
      render_unprocessable(creation_service.errors)
    end
  end

  private

  def creation_service
    @creation_service ||= CapitalsCreationService.call(
      assessment_id: params[:assessment_id],
      bank_accounts_attributes: input.dig(:liquid_capital, :bank_accounts),
      non_liquid_capitals_attributes: input[:non_liquid_capital]
    )
  end

  def input
    @input ||= JSON.parse(request.raw_post, symbolize_names: true)
  end
end

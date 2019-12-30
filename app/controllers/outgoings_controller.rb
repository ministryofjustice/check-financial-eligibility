class OutgoingsController < ApplicationController
  # api! works but the links in resulting docs are broken. See https://github.com/Apipie/apipie-rails/issues/559
  api :POST, 'assessments/:assessment_id/outgoings', 'Create outgoings'
  formats ['json']
  param :assessment_id, :uuid, required: true

  param :outgoings, Hash, required: true do
    param :childcare, Array, desc: 'Collection of childcare payments made', required: true do
      param :payment_date, Date, date_option: :today_or_older, required: true, desc: 'The date the childcare payment was made'
      param :amount, :currency, required: true, desc: 'The monetary amount paid for the childcare'
    end

    param :maintenance, Array, desc: 'Collection of maintenance payments made', required: true do
      param :payment_date, Date, date_option: :today_or_older, required: true, desc: 'The date the maintenance payment was made'
      param :amount, :currency, required: true, desc: 'The monetary value of the maintenance payment'
    end

    param :housing_costs, Array, desc: 'Collection of housing cost payment', required: true do
      param :payment_date, Date, date_option: :today_or_older, required: true, desc: 'The date the housing cost payment was made'
      param :amount, :currency, required: true, desc: 'The monetary amount paid for the housing cost'
      param :housing_cost_type, String, required: true, desc: 'Type of housing cost, one of: rent, mortgage, board_and_lodging'
    end
  end

  returns code: :ok, desc: 'Successful response' do
    property :outgoings, array_of: Outgoings::BaseOutgoing, desc: 'Array of created outgoing objects'
    property :success, ['true'], desc: 'Success flag shows true'
  end

  returns code: :unprocessable_entity do
    property :errors, array_of: String, desc: 'Description of why object invalid'
    property :success, ['false'], desc: 'Success flag shows false'
  end

  def create
    if outgoing_creation_service.success?
      render json: {
        outgoings: outgoing_creation_service.outgoings,
        success: true,
        errors: []
      }
    else
      render_unprocessable(outgoing_creation_service.errors)
    end
  end

  private

  def outgoing_creation_service
    @outgoing_creation_service ||= Creators::OutgoingsCreator.call(
      outgoings: input[:outgoings],
      assessment_id: params[:assessment_id]
    )
  end

  def input
    @input ||= JSON.parse(request.raw_post, symbolize_names: true)
  end
end

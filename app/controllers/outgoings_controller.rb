class OutgoingsController < ApplicationController
  # api! works but the links in resulting docs are broken. See https://github.com/Apipie/apipie-rails/issues/559
  api :POST, 'assessments/:assessment_id/outgoings', 'Create outgoings'
  formats ['json']
  param :assessment_id, :uuid, required: true

  param :outgoings, Array, desc: 'Collection of other outgoing types' do
    param :name, Creators::OutgoingsCreator::VALID_OUTGOING_TYPES, required: true, desc: 'The type of outgoing'
    param :payments, Array, desc: 'Collection of payment dates and amounts' do
      param :payment_date, Date, date_option: :today_or_older, required: true, desc: 'The date payment made'
      param :housing_costs_type, %w[rent mortgage board_and_lodging], required: false, desc: 'The type of housing cost (omit for non-housing cost outgoings)'
      param :amount, :currency, 'Amount of payment'
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

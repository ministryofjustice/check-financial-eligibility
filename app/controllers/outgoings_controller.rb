class OutgoingsController < ApplicationController
  # api! works but the links in resulting docs are broken. See https://github.com/Apipie/apipie-rails/issues/559
  api :POST, 'assessments/:assessment_id/outgoings', 'Create outgoings'
  formats ['json']
  param :assessment_id, :uuid, required: true
  param :outgoings, Array, desc: 'Collection of outgoings', required: true do
    param :outgoing_type, Outgoing.outgoing_types.values, required: true, desc: 'The type of product or service the outgoing paid for'
    param :payment_date, Date, date_option: :today_or_older, required: true, desc: 'The date the outgoing was paid'
    param :amount, :currency, required: true, desc: 'The monetary amount paid for the outgoing'
  end

  returns code: :ok, desc: 'Successful response' do
    property :outgoings, array_of: Outgoing, desc: 'Array of created outgoing objects'
    property :success, ['true'], desc: 'Success flag shows true'
  end
  returns code: :unprocessable_entity do
    property :errors, array_of: String, desc: 'Description of why object invalid'
    property :success, ['false'], desc: 'Success flag shows false'
  end

  def create
    if outgoing_creation_service.success?
      render json: outgoing_creation_service
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

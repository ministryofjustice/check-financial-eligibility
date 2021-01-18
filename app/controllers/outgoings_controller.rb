class OutgoingsController < ApplicationController
  # api! works but the links in resulting docs are broken. See https://github.com/Apipie/apipie-rails/issues/559
  api :POST, 'assessments/:assessment_id/outgoings', 'Create outgoings'
  formats ['json']
  param :assessment_id, :uuid, required: true

  param :outgoings, Array, desc: 'Collection of other outgoing types' do
    param :name, CFEConstants::VALID_OUTGOING_CATEGORIES, required: true, desc: 'The type of outgoing'
    param :payments, Array, desc: 'Collection of payment dates and amounts' do
      param :payment_date, Date, date_option: :today_or_older, required: true, desc: 'The date payment made'
      param :housing_costs_type, %w[rent mortgage board_and_lodging], required: false, desc: 'The type of housing cost (omit for non-housing cost outgoings)'
      param :amount, :currency, currency_option: :not_negative, required: true, desc: 'Amount of payment'
      param :client_id, String, required: true, desc: 'Uniquely identifying string from client'
    end
  end

  returns code: :ok, desc: 'Successful response' do
    property :success, ['true'], desc: 'Success flag shows true'
    property :errors, [], desc: 'Empty array of error messages'
  end
  returns code: :unprocessable_entity do
    property :success, ['false'], desc: 'Success flag shows false'
    property :errors, array_of: String, desc: 'Description of why object invalid'
  end

  def create
    if outgoing_creation_service.success?
      render_success
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

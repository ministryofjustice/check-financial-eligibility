class VehiclesController < ApplicationController
  api :POST, 'assessments/:assessment_id/vehicles', 'Create vehicles'
  formats ['json'] # rubocop:disable Layout/SpaceBeforeBrackets
  param :assessment_id, :uuid, required: true
  param(
    :vehicles,
    Array,
    desc: 'An array of vehicles owned by the applicant',
    required: true
  ) do
    param :value, :currency, required: true, desc: 'Value of the vehicle'
    param :loan_amount_outstanding, :currency, required: false, desc: 'Amount, if any, of a loan used to purchase the vehicle which is still left to pay'
    param :date_of_purchase, Date, date_option: :today_or_older, required: true, desc: 'Date the vehicle was purchased by the applicant'
    param :in_regular_use, :boolean, required: false, desc: 'Whether or not the vehicle is in regular use'
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
    if creation_service.success?
      render_success
    else
      render_unprocessable(creation_service.errors)
    end
  end

  private

  def creation_service
    @creation_service ||= Creators::VehicleCreator.call(
      assessment_id: params[:assessment_id],
      vehicles_attributes: input[:vehicles]
    )
  end

  def input
    @input ||= JSON.parse(request.raw_post, symbolize_names: true)
  end
end

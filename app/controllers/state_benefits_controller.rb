class StateBenefitsController < ApplicationController
  resource_description do
    short 'Add state benefits to an assessment'
    formats ['json']
    description <<-END_OF_TEXT
    == Description
      Adds details of an applicants'state benefits to an assessment.
    END_OF_TEXT
  end

  api :POST, 'assessments/:assessment_id/state_benefit', 'Create state benefit'
  formats ['json']
  param :assessment_id, :uuid, required: true
  param :state_benefits, Array, desc: 'Collection of state benefits' do
    param :name, String, required: true, desc: 'The state benefit name'
    param :payments, Array, desc: 'Collection of payment dates and amounts' do
      param :date, Date, date_option: :today_or_older, required: true, desc: 'The date payment received'
      param :amount, :currency, required: true, desc: 'Amount of payment'
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
    if creation_service.success?
      render_success
    else
      render_unprocessable(creation_service.errors)
    end
  end

  private

  def creation_service
    @creation_service ||= Creators::StateBenefitsCreator.call(
      assessment_id: params[:assessment_id],
      state_benefits: state_benefit_params
    )
  end

  def state_benefit_params
    JSON.parse(request.raw_post, symbolize_names: true)
  end
end

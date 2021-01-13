class CapitalsController < ApplicationController
  resource_description do
    short 'Add capital details to an assessment'
    formats ['json']
    description <<-END_OF_TEXT
    == Description
      Adds details of an applicant's capital assets to an assessment.

      There are two types of assets:

        - bank_accounts  The description should hold the Bank name and account
          number, and the value should hold the lowest balance during that calculation period (i.e. the
          month leading up to the submission date)

        - non-liquid capital items:  These are other capital assets which are not immediately realisable as cash, such
          as stocks and shares, interest in a trust, valuable items, etc.  Do not include property or vehicles which
          are added through separate endpoints.
    END_OF_TEXT
  end
  api :POST, 'assessments/:assessment_id/capitals', 'Create capital declarations'
  formats ['json']
  param :assessment_id, :uuid, required: true
  param :bank_accounts, Array, desc: 'Collection of bank accounts' do
    param :description, String, required: true, desc: 'An identifying name for this bank account'
    param :value, :currency, required: true, desc: 'The lowest balance on this bank account during the calculation period'
  end

  param :non_liquid_capital, Array, desc: 'Collection of non-liquid capital assets' do
    param :description, String, required: true, desc: 'An description of this non-liquid asset'
    param :value, :currency, required: true, desc: 'Estimated value of this non-liquid asset'
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
    @creation_service ||= Creators::CapitalsCreator.call(
      assessment_id: params[:assessment_id],
      bank_accounts_attributes: input[:bank_accounts],
      non_liquid_capitals_attributes: input[:non_liquid_capital]
    )
  end

  def input
    @input ||= JSON.parse(request.raw_post, symbolize_names: true)
  end
end

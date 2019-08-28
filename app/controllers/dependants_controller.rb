class DependantsController < ApplicationController
  api :POST, '/assessments/:assessment_id/dependants', 'Create dependants'
  formats ['json']
  param :dependants, Array, required: true, desc: 'An Array of Objects describing a dependant' do
    param :date_of_birth, Date, date_option: :today_or_older, required: true, desc: 'The date of birth of the dependant'
    param :in_full_time_education, :boolean, required: true, desc: 'Whether or not the dependant is in full time education'
    param :relationship, Dependant.relationships.values, required: true, desc: "What is the dependant's relationship to the applicant"
    param :monthly_income, :currency, required: false, desc: 'What is the monthly income of the dependant'
    param :assets_value, :currency, required: false, desc: 'What is the total assets value of the dependant'
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
      render_success objects: creation_service.dependants
    else
      render_unprocessable(creation_service.errors)
    end
  end

  private

  def creation_service
    @creation_service ||= DependantsCreationService.call(
      assessment_id: params[:assessment_id],
      dependants_attributes: input[:dependants]
    )
  end

  def input
    @input ||= JSON.parse(request.raw_post, symbolize_names: true)
  end
end

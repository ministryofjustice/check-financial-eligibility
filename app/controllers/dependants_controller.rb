class DependantsController < ApplicationController
  api :POST, '/assessments/:assessment_id/dependants', 'Create dependants'
  formats ['json']
  param :dependants, Array, required: true, desc: 'An Array of Objects describing a dependant' do
    param :date_of_birth, Date, date_option: :today_or_older, required: true, desc: 'The date of birth of the dependant'
    param :in_full_time_education, :boolean, required: true, desc: 'Whether or not the dependant is in full time education'
    param :income, Array, required: false, desc: "An array of objects describing the dependent's income receipts during the calculation period" do
      param :date_of_payment, Date, required: true, desc: 'The date the dependent received this income'
      param :amount, :currency, required: true, desc: 'The amount of income received'
    end
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
      render_success objects: creation_service.dependants.map { |dependant| DependantSerializer.new(dependant) }
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

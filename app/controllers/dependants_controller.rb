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
    if creation_service_result.success?
      render json: {
        success: true,
        objects: creation_service_result.dependants.map { |dependant| DependantSerializer.new(dependant) },
        errors: []
      }
    else
      render json: {
        success: false,
        objects: nil,
        errors: creation_service_result.errors
      }, status: 422
    end
  end

  private

  def creation_service_result
    @creation_service_result ||= DependantsCreationService.call(request.raw_post)
  end
end

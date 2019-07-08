class ApplicantsController < ApplicationController
  api :POST, 'assessments/:assessment_id/applicant', 'Create applicant'
  formats ['json']
  param :assessment_id, :uuid, required: true, desc: 'The assessment id to which this applicant relates'
  param :applicant, Hash, desc: 'Describes basic info about the applicant', required: true do
    param :date_of_birth, Date, date_option: :today_or_older, required: true, desc: "The applicant's date of birth"
    param :involvement_type, ['Applicant'], required: true, desc: 'How the applicant is involved in the case'
    param :has_partner_opponent, :boolean, require: true, desc: "Whether or not the applicant's partner is an opponent in the case"
    param :receives_qualifying_benefit, :boolean, required: true, desc: 'Whether or not the applicant receives a qualifying benefit'
  end

  returns code: :ok, desc: 'Successful response' do
    property :objects, array_of: Applicant
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
        objects: [creation_service_result.applicant],
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
    @creation_service_result ||= ApplicantCreationService.call(request.raw_post)
  end
end

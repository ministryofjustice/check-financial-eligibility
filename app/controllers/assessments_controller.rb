class AssessmentsController < ApplicationController
  api :POST, 'asssessments', 'Create asssessment'
  formats ['json']
  param :client_reference_id, String, "The client's reference number for this application"
  param :submission_date, Date, date_option: :today_or_older, required: true, desc: 'The date of the original submission'
  param :matter_proceeding_type, ['domestic_abuse'], required: true, desc: 'The matter type of the case'

  returns code: :ok, desc: 'Successful response' do
    property :objects, array_of: Assessment
    property :success, ['true'], desc: 'Success flag shows true'
  end
  returns code: :unprocessable_entity do
    property :errors, array_of: String, desc: 'Description of why object invalid'
    property :success, ['false'], desc: 'Success flag shows false'
  end

  def create
    if assessment_creation_service.success?
      render json: assessment_creation_service
    else
      render_unprocessable(assessment_creation_service.errors)
    end
  end

  private

  def assessment_creation_service
    @assessment_creation_service ||= AssessmentCreationService.call(request.remote_ip, request.raw_post)
  end
end

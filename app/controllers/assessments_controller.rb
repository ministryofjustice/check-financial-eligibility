class AssessmentsController < ApplicationController
  resource_description do
    short 'Create a new assessment'
    formats ['json']
    description <<-END_OF_TEXT
    == Description
      This endpoint should be called first to create an Assessment. Then using the
      assessment_id returned by this call, other resources should be called to build
      up the complete set of data relating to the assessment:

        POST /assessments/:assessment_id/applicant      # adds data about the applicant
        POST /assessments/:assessment_id/capitals       # adds data about liquid assets (i.e. bank accounts) and
                                                        # non-liquid assets (valuable items, trusts, etc)
        POST /assessments/:assessment_id/properties     # adds data about properties owned by the applicant
        POST /assessments/:assessment_id/vehicles       # adds data about vehicles owned by the applicant
        POST /assessments/:assessment_id/dependants     # adds data about any dependents the applicant may have
        POST /assessments/:assessment_id/incomes        # adds data about any income the applicant may have

      Once all the above calls have been made to build up a complete picture of the applicant's assets and income
      the following call should be made to perform the assessment and get the result:

        GET /assessment/:assessment_id

    END_OF_TEXT
  end
  api :POST, 'assessments', 'Create asssessment'
  formats ['json']
  param :client_reference_id, String, "The client's reference number for this application (free text)"
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

  api :GET, 'assessments/:assessment_id', 'Perform assessment and return result'
  formats ['json']
  returns code: :ok, desc: 'Assessment result details' do
    property :result, Hash
  end

  # performs the assessment and returns the result
  def show
    WorkflowManager.new(params[:id], StandardWorkflow.workflow).call
    assessment = Assessment.find(params[:id])
    render json: assessment.result
  end

  private

  def assessment_creation_service
    @assessment_creation_service ||= AssessmentCreationService.call(request.remote_ip, request.raw_post)
  end
end

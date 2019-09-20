class AssessmentsController < ApplicationController
  resource_description do
    short 'Assessment container'
    formats ['json']
    description <<~END_OF_TEXT
      The assessment is the container that holds the data used to make the assessment. Its `id` is used to identify the
      current assessment in other endpoints.

      At the end of the process, the completed assessment will include the result.
    END_OF_TEXT
  end

  api :POST, 'assessments', 'Create asssessment'
  formats ['json']
  param :client_reference_id, String, "The client's reference number for this application (free text)"
  param :submission_date, Date, date_option: :today_or_older, required: true, desc: 'The date of the original submission'
  param :matter_proceeding_type, Assessment.matter_proceeding_types.values, required: true, desc: 'The matter type of the case'

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

  api :GET, 'assessments/:id', 'Get assessment result'
  formats ['json']
  param :id, :uuid, required: true

  returns code: :ok, desc: 'Successful response - see example for detail' do
    property :assessment_result, %w[eligible not_eligible contribution_required]
    property :applicant, Hash, desc: 'Applicant data used for assessment'
    property :capital, Hash, desc: 'Capital data used for assessment'
    property :property, Hash, desc: 'Property data used for assessment'
    property :vehicles, Hash, desc: 'Vehicle data used for assessment'
  end

  def show
    assessment.summarise!
    assessment.determine_result!
    render json: ResultDecorator.new(assessment)
  end

  private

  def assessment_creation_service
    @assessment_creation_service ||= AssessmentCreationService.call(request.remote_ip, request.raw_post)
  end

  def assessment
    @assessment ||= Assessment.find(params[:id])
  end
end

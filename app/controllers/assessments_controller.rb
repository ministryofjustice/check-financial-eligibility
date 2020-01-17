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

  api :POST, 'assessments', 'Create assessment'
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

  def self.documentation_for_get
    %(Get assessment result<br/>
       Note that there are two versions of this api.  The version is specified by the Accept header, for example</br>
       <tt>&nbsp;&nbsp;&nbsp;&nbsp;Accept:application/json;version=2</tt><br/>
       If the version part of the Accept header is not specified, version 1 is assumed<br/<br/>
       In the given examples, the first two examples are version 1, the third example is version 2.<br/>)
  end

  api :GET, 'assessments/:id', AssessmentsController.documentation_for_get
  formats ['json']
  param :id, :uuid, required: true

  returns code: :ok, desc: 'Successful response - see example for detail' do
    property :assessment_result, %w[eligible ineligible contribution_required]
    property :applicant, Hash, desc: 'Applicant data used for assessment'
    property :capital, Hash, desc: 'Capital data used for assessment'
    property :property, Hash, desc: 'Property data used for assessment'
    property :vehicles, Hash, desc: 'Vehicle data used for assessment'
  end

  def show
    case determine_version
    when '1'
      show_v1
    when '2'
      show_v2
    else
      render json: Decorators::ErrorDecorator.new('Unsupported version specified in AcceptHeader').as_json, status: :unprocessable_entity
    end
  end

  private

  def show_v1
    if applicant_passported?
      Workflows::MainWorkflow.call(assessment)
      Assessors::MainAssessor.call(assessment)
      render json: Decorators::ResultDecorator.new(assessment)
    else
      render json: Decorators::ErrorDecorator.new('Version 1 of the API is not able to process un-passported applications').as_json, status: :unprocessable_entity
    end
  end

  def show_v2
    render json: Decorators::AssessmentDecorator.new(assessment).as_json
  end

  def determine_version
    parts = request.headers['Accept'].split(';')
    parts.each do |part|
      return Regexp.last_match(1) if part =~ /^version=(\d)$/
    end
    '1'
  end

  def assessment_creation_service
    @assessment_creation_service ||= Creators::AssessmentCreator.call(request.remote_ip, request.raw_post)
  end

  def assessment
    @assessment ||= Assessment.find(params[:id])
  end

  def applicant_passported?
    assessment.applicant.receives_qualifying_benefit?
  end
end

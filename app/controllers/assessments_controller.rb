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
    property :success, ['true'], desc: 'Success flag shows true'
    property :assessment_id, :uuid
    property :errors, [], desc: 'Empty array of error messages'
  end
  returns code: :unprocessable_entity do
    property :success, ['false'], desc: 'Success flag shows false'
    property :errors, array_of: String, desc: 'Description of why object invalid'
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
       Only version 2 of this api is currently valid.  The version is specified by the Accept header, for example</br>
       <tt>&nbsp;&nbsp;&nbsp;&nbsp;Accept:application/json;version=2</tt><br/>
       If the version part of the Accept header is not specified, version 2 is assumed<br/<br/>
     )
  end

  api :GET, 'assessments/:id', AssessmentsController.documentation_for_get
  formats ['json']
  param :id, :uuid, required: true

  returns code: :ok, desc: 'Successful response - see example for detail' do
    property :assessment_result, %w[eligible ineligible contribution_required]
    property :applicant, Hash, desc: 'Applicant data used for assessment'
    property :capital, Hash, desc: 'Capital data used for assessment'
    property :other_incomes, Hash, desc: 'Other income data used for assessment'
    property :property, Hash, desc: 'Property data used for assessment'
    property :vehicles, Hash, desc: 'Vehicle data used for assessment'
  end

  def show
    determine_version_and_process
  rescue StandardError => err
    Raven.capture_exception(err)
    render json: Decorators::ErrorDecorator.new(err).as_json, status: :unprocessable_entity
  end

  private

  def determine_version_and_process
    case determine_version
    when '2'
      show_v2
    else
      raise CheckFinancialEligibilityError, 'Unsupported version specified in AcceptHeader'
    end
  end

  def show_v2
    Workflows::MainWorkflow.call(assessment)
    Assessors::MainAssessor.call(assessment)
    render json: Decorators::AssessmentDecorator.new(assessment).as_json
  end

  def determine_version
    parts = request.headers['Accept'].split(';')
    parts.each do |part|
      return Regexp.last_match(1) if part =~ /^version=(\d)$/
    end
    '2'
  end

  def assessment_creation_service
    @assessment_creation_service ||= Creators::AssessmentCreator.call(request.remote_ip, request.raw_post)
  end

  def assessment
    @assessment ||= Assessment.find(params[:id])
  end
end

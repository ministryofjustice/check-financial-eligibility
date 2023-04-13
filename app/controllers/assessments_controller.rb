class AssessmentsController < CreationController
  before_action :validate, only: [:create]

  def create
    if assessment_creation_service.success?
      render json: { success: true, assessment_id: assessment_creation_service.assessment.id, errors: [] }
    else
      render_unprocessable(assessment_creation_service.errors)
    end
  end

  def show
    if assessment_incomplete?
      render json: Decorators::ErrorDecorator.new(incomplete_message).as_json, status: :unprocessable_entity
    else
      perform_assessment
    end
  rescue StandardError => e
    Sentry.capture_exception(e)
    render json: Decorators::ErrorDecorator.new(e).as_json, status: :unprocessable_entity
  end

private

  def validate
    validate_json_schema "assessment", assessment_params
  end

  def assessment_incomplete?
    assessment.proceeding_types.empty? || assessment.applicant.nil?
  end

  def incomplete_message
    "You must add proceeding types and applicant to before calling for the assessment to be calculated"
  end

  def perform_assessment
    calculation_output = Workflows::MainWorkflow.call(assessment)
    render json: decorator_klass.new(assessment, calculation_output).as_json
  end

  def version
    accept_header_parts = request.headers["Accept"].split(";")
    version_part = accept_header_parts.detect { |part| part.strip =~ /^version=(\d+)$/ }
    return CFEConstants::DEFAULT_ASSESSMENT_VERSION if version_part.nil?

    Regexp.last_match(1)
  end

  def assessment_creation_service
    @assessment_creation_service ||= Creators::AssessmentCreator.call(remote_ip: request.remote_ip, assessment_params:, version:)
  end

  def assessment_params
    JSON.parse(request.raw_post, symbolize_names: true)
  end

  def assessment
    @assessment ||= Assessment.find(params[:id])
  end

  def decorator_klass
    Decorators::V5::AssessmentDecorator
  end
end

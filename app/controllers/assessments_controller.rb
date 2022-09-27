class AssessmentsController < ApplicationController
  def create
    if assessment_creation_service.success?
      render json: assessment_creation_service
    else
      render_unprocessable(assessment_creation_service.errors)
    end
  end

  def show
    case analyse_assessment_status
    when :incomplete
      render json: Decorators::ErrorDecorator.new(incomplete_message).as_json, status: :unprocessable_entity
    when :not_pending
      render json: Decorators::ErrorDecorator.new(not_pending_message).as_json, status: :unprocessable_entity
    else
      perform_assessment
    end
  rescue StandardError => e
    Sentry.capture_exception(e)
    render json: Decorators::ErrorDecorator.new(e).as_json, status: :unprocessable_entity
  end

private

  def analyse_assessment_status
    return :incomplete if assessment_incomplete?

    return :pending if assessment.assessment_result == "pending"

    :not_pending
  end

  def assessment_incomplete?
    assessment.proceeding_types.empty? || assessment.applicant.nil?
  end

  def incomplete_message
    "You must add proceeding types and applicant to before calling for the assessment to be calculated"
  end

  def not_pending_message
    "Unable to call GET on the same assessment twice - please create new assessment and resubmit data"
  end

  def perform_assessment
    Workflows::MainWorkflow.call(assessment)
    render json: decorator_klass.new(assessment).as_json
  end

  def version
    accept_header_parts = request.headers["Accept"].split(";")
    version_part = accept_header_parts.detect { |part| part.strip =~ /^version=(\d+)$/ }
    return CFEConstants::DEFAULT_ASSESSMENT_VERSION if version_part.nil?

    Regexp.last_match(1)
  end

  def assessment_creation_service
    @assessment_creation_service ||= Creators::AssessmentCreator.call(remote_ip: request.remote_ip, assessment_params: request.raw_post, version:)
  end

  def assessment
    @assessment ||= Assessment.find(params[:id])
  end

  def decorator_klass
    Decorators::V5::AssessmentDecorator
  end
end

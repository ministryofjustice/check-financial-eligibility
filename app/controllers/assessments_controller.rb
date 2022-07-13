class AssessmentsController < ApplicationController
  def create
    if assessment_creation_service.success?
      render json: assessment_creation_service
    else
      render_unprocessable(assessment_creation_service.errors)
    end
  end

  def show
    perform_assessment
  rescue StandardError => e
    Sentry.capture_exception(e)
    render json: Decorators::ErrorDecorator.new(e).as_json, status: :unprocessable_entity
  end

private

  def perform_assessment
    Workflows::MainWorkflow.call(assessment)
    render json: decorator_klass.new(assessment).as_json
  end

  def version
    version = CFEConstants::DEFAULT_ASSESSMENT_VERSION
    parts = request.headers["Accept"].split(";")
    parts.each { |part| version = Regexp.last_match(1) if part.strip =~ /^version=(\d)$/ }
    version
  end

  def assessment_creation_service
    @assessment_creation_service ||= Creators::AssessmentCreator.call(remote_ip: request.remote_ip, assessment_params: request.raw_post, version:)
  end

  def assessment
    @assessment ||= Assessment.find(params[:id])
  end

  def decorator_klass
    if assessment.version_3?
      Decorators::V3::AssessmentDecorator
    elsif assessment.version_4?
      Decorators::V4::AssessmentDecorator
    else
      Decorators::V5::AssessmentDecorator
    end
  end
end

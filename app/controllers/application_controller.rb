class ApplicationController < ActionController::API
  around_action :log_request

  class ErrorSerializer < ApiErrorHandler::Serializers::BaseSerializer
    def serialize(_serializer_options)
      { success: false, errors: ["#{@error.class}: #{@error.message}"] }
    end

    def render_format
      :json
    end
  end

  handle_api_errors(serializer: ErrorSerializer, error_reporter: :sentry)

  def render_unprocessable(message)
    sentry_message = message.is_a?(Array) ? message.join(", ") : message
    Sentry.capture_message(sentry_message)
    render json: { success: false, errors: message }, status: :unprocessable_entity
  end

  def render_success
    render json: { success: true, errors: [] }
  end

  def log_request
    start_time = Time.zone.now
    rec = RequestLog.create_from_request(request) if /^\/assessment/.match?(request.path)
    yield
    duration = Time.zone.now - start_time
    rec.update_from_response(response, duration) if /^\/assessment/.match?(request.path)
  end
end

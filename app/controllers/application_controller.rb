class ApplicationController < ActionController::API
  rescue_from StandardError do |e|
    Sentry.capture_exception(e)
    render json: { success: false, errors: ["#{e.class}: #{e.message}"] }, status: :unprocessable_entity
  end
  rescue_from Apipie::ParamError do |e|
    Sentry.capture_exception(e)
    render json: { success: false, errors: [e.message] }, status: :unprocessable_entity
  end

  def render_unprocessable(message)
    sentry_message = message.is_a?(Array) ? message.join(", ") : message
    Sentry.capture_message(sentry_message)
    render json: { success: false, errors: message }, status: :unprocessable_entity
  end

  def render_success
    render json: { success: true, errors: [] }
  end
end

class ApplicationController < ActionController::API
  rescue_from StandardError do |e|
    Raven.capture_exception(e)
    render json: { success: false, errors: ["#{e.class}: #{e.message}"] }, status: :unprocessable_entity
  end
  rescue_from Apipie::ParamError do |e|
    Raven.capture_exception(e)
    render json: { success: false, errors: [e.message] }, status: :unprocessable_entity
  end

  def render_unprocessable(message)
    raven_message = message.is_a?(Array) ? message.join(', ') : message
    Raven.capture_message(raven_message)
    render json: { success: false, errors: message }, status: :unprocessable_entity
  end

  def render_success
    render json: { success: true, errors: [] }
  end
end

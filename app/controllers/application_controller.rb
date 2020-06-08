class ApplicationController < ActionController::API
  rescue_from StandardError do |e|
    render_unprocessable([e.message])
    Raven.capture_exception(e)
  end

  def render_unprocessable(message)
    Raven.capture_exception(message)
    render json: { success: false, errors: message }, status: :unprocessable_entity
  end

  def render_success
    render json: { success: true, errors: [] }
  end
end

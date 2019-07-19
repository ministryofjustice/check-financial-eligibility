class ApplicationController < ActionController::API
  rescue_from Apipie::ParamError do |e|
    render_unprocessable([e.message])
  end

  def render_unprocessable(message)
    render json: { errors: message, success: false }, status: :unprocessable_entity
  end

  def render_success(response)
    render json: response.merge(errors: [], success: true)
  end
end

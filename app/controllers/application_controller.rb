class ApplicationController < ActionController::API
  rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
  rescue_from StandardError, with: :handle_standard_error

  private

  def handle_parameter_missing(exception)
    render_error(:bad_request, exception.message)
  end

  def handle_not_found(exception)
    render_error(:not_found, exception.message)
  end

  def handle_standard_error(exception)
    Rails.logger.error(exception.full_message)
    render_error(:internal_server_error, exception.message)
  end

  def render_error(status, message)
    render json: { error: message }, status: status
  end
end

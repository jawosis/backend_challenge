class ApplicationController < ActionController::API
  include ActionController::ParamsWrapper
  wrap_parameters format: [:json]
  around_filter :catch_not_found_error

  def render_with_status(success, code, object=nil, errors=nil)
    object_hash = success ? object.as_json : {:errors => errors.present? ? errors : true}
    render json: object_hash, status: code
  end

  def routing_error
    render_with_status(false, :bad_request, nil, "Invalid path!" )
  end

  private

  def catch_not_found_error
    yield
  rescue ActiveRecord::RecordNotFound
    render_with_status(false, :not_found, nil, "Record not found!" )
  end
end

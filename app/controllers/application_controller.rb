require 'response_creator'

class ApplicationController < ActionController::API
  private

  def render_response(result, success_code: 200)
    response_data = ResponseCreator.new.call(result, success_code: success_code)
    render json: response_data.message, status: response_data.status_code
  end
end

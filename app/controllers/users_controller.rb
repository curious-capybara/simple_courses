# @private
class UsersController < ApplicationController
  def create
    result = UserDomain.create_user(email: params[:email])
    render_response(result, success_code: 201)
  end

  def destroy
    result = UserDomain.delete_user(id: params[:id])
    render_response(result)
  end

  def courses
    result = CourseDomain.list_by_user(user_id: params[:id])
    render_response(result)
  end
end

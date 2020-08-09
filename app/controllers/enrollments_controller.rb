class EnrollmentsController < ApplicationController
  def create
    result = CourseDomain.enroll_user(user_id: params[:user_id], course_id: params[:course_id])
    render_response(result, success_code: 201)
  end

  def destroy
    result = CourseDomain.withdraw_user(user_id: params[:user_id], course_id: params[:course_id])
    render_response(result)
  end
end

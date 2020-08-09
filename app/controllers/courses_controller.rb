class CoursesController < ApplicationController
  def create
    result = CourseDomain.create_course(name: params[:name])
    render_response(result, success_code: 201)
  end

  def destroy
    result = CourseDomain.delete_course(id: params[:id])
    render_response(result)
  end

  def index
    result = CourseDomain.list_courses
    render_response(result)
  end
end

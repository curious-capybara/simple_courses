# frozen_string_literal: true

require 'dry/monads'

module CourseDomain
  extend Dry::Monads[:result]

  # Creates a new course
  #
  # @param name [String] title of the course
  def self.create_course(name:)
    course = Course.new(name: name)
    if course.save
      Success(course)
    else
      Failure([:failed, course.errors.messages])
    end
  rescue StandardError => e
    Failure([:error, e])
  end

  # Deletes a course by id
  #
  # @param id [Integer] course id
  def self.delete_course(id:)
    course = Course.find_by(id: id)
    if course
      course.destroy
      Success(course)
    else
      Failure([:failed, { base: ['course does not exist'] }])
    end
  rescue StandardError => e
    Failure([:error, e])
  end

  # Enrols user to the course
  #
  # @param user_id [Integer] ID of the enrolled user
  # @param course_id [Integer] ID of the course user enrolls into
  def self.enroll_user(course_id:, user_id:)
    course = Course.find_by(id: course_id)
    return Failure([:failed, { course: ['must exist'] }]) unless course

    existing = Enrollment.find_by(user_id: user_id, course_id: course_id)
    return Failure([:failed, { base: ['user already enrolled'] }]) if existing

    enrollment = course.enrollments.build(user_id: user_id)
    if enrollment.save
      Success(enrollment)
    else
      Failure([:failed, enrollment.errors.messages])
    end
  rescue StandardError => e
    Failure([:error, e])
  end

  # Withdraws the user from the course
  #
  # @param user_id [Integer] ID of the user to withdraw
  # @param course_id [Integer] ID of the course to withdraw user from
  def self.withdraw_user(course_id:, user_id:)
    course = Course.find_by(id: course_id)
    return Failure([:failed, { course: ['must exist'] }]) unless course

    enrollment = Enrollment.find_by(user_id: user_id, course_id: course_id)
    return Failure([:failed, { base: ['user is not enrolled'] }]) unless enrollment

    enrollment.destroy
    Success(enrollment)
  rescue StandardError => e
    Failure([:error, e])
  end

  # Returns list of courses with number of users enrolled
  def self.list_courses
    results = Course.left_joins(enrollments: [:user]).group('courses.id').select('courses.*, count(users.id) as enrollments_count').to_a
    Success(results)
  rescue StandardError => e
    Failure([:error, e])
  end

  # Returns courses user is enrolled to
  #
  # @param [id] User ID
  def self.list_by_user(user_id:)
    user = User.find_by(id: user_id)
    return Failure([:failed, { base: ['user does not exist'] }]) unless user

    Success(user.courses.to_a)
  end
end

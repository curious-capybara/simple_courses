# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CourseDomain do
  include Dry::Monads[:result]

  let(:name) { 'Ruby 101' }

  describe '#create_course' do
    context 'with correct params' do
      let(:result) { CourseDomain.create_course(name: name) }

      it 'creates a course' do
        expect { result }.to change { Course.count }.by(1)
      end

      it 'returns success' do
        expect(result).to be_success
        expect(result.value!).to be_persisted
        expect(result.value!).to be_kind_of(Course)
        expect(result.value!.name).to eq(name)
      end
    end

    context 'with empty name' do
      let(:result) { CourseDomain.create_course(name: nil) }

      it 'does not create a course' do
        expect { result }.not_to change { Course.count }
      end

      it 'returns failure' do
        expect(result).to be_failure
        expect(result.failure).to eq([:failed, { name: ["can't be blank"] }])
      end
    end
  end

  describe '#delete_course' do
    let!(:course) { Course.create!(name: name) }

    context 'when course exists' do
      let(:result) { CourseDomain.delete_course(id: course.id) }

      it 'deletes a course' do
        expect { result }.to change { Course.count }.by(-1)
      end

      it 'returns success' do
        expect(result).to be_success
      end
    end

    context 'when course does not exist' do
      let(:result) do
        last_id = Course.order(:id).last&.id || 0
        CourseDomain.delete_course(id: last_id + 1)
      end

      it 'returns failure' do
        expect(result).to be_failure
        expect(result.failure).to eq([:failed, { base: ['course does not exist'] }])
      end
    end
  end

  describe '#enroll_user' do
    let(:user) { User.create!(email: 'test@example.com') }
    let(:course) { Course.create!(name: 'test course') }

    context 'with correct params' do
      let(:result) { CourseDomain.enroll_user(user_id: user.id, course_id: course.id) }

      it 'creates an enrollment' do
        expect { result }.to change { Enrollment.count }.by(1)
      end

      it 'returns success' do
        expect(result).to be_success
        expect(result.value!).to be_kind_of(Enrollment)
        expect(result.value!.user).to eq(user)
        expect(result.value!.course).to eq(course)
      end
    end

    context 'with existing enrollment' do
      before { Enrollment.create!(user: user, course: course) }
      let(:result) { CourseDomain.enroll_user(user_id: user.id, course_id: course.id) }

      it 'does not create an enrollment' do
        expect { result }.not_to change { Enrollment.count }
      end

      it 'returns failure' do
        expect(result).to be_failure
        expect(result.failure).to eq([:failed, { base: ['user already enrolled'] }])
      end
    end

    context 'with non-existing user' do
      let(:result) { CourseDomain.enroll_user(user_id: user.id + 100, course_id: course.id) }

      it 'returns failure' do
        expect(result).to be_failure
        expect(result.failure).to eq([:failed, { user: ['must exist'] }])
      end
    end

    context 'with non-existing course' do
      let(:result) { CourseDomain.enroll_user(user_id: user.id, course_id: course.id + 100) }


      it 'returns failure' do
        expect(result).to be_failure
        expect(result.failure).to eq([:failed, { course: ['must exist'] }])
      end
    end
  end

  describe '#withdraw_user' do
    let(:user) { User.create!(email: 'test@example.com') }
    let(:course) { Course.create!(name: 'test course') }

    context 'with correct params' do
      let!(:enrollment) { Enrollment.create!(user: user, course: course) }
      let(:result) { CourseDomain.withdraw_user(user_id: user.id, course_id: course.id) }

      it 'deletes enrollment' do
        expect { result }.to change { Enrollment.count }.by(-1)
      end

      it 'return success' do
        expect(result).to eq(Success(enrollment))
      end
    end

    context 'with non-existing user' do
      let(:result) { CourseDomain.withdraw_user(user_id: user.id + 100, course_id: course.id) }

      it 'returns failure' do
        expect(result).to be_failure
        expect(result.failure).to eq([:failed, { base: ['user is not enrolled'] }])
      end
    end

    context 'with non-existing course' do
      let(:result) { CourseDomain.withdraw_user(user_id: user.id, course_id: course.id + 100) }

      it 'returns failure' do
        expect(result).to be_failure
        expect(result.failure).to eq([:failed, { course: ['must exist'] }])
      end
    end

    context 'with non-existing enrollment' do
      let(:result) { CourseDomain.withdraw_user(user_id: user.id, course_id: course.id) }

      it 'returns failure' do
        expect(result).to be_failure
        expect(result.failure).to eq([:failed, { base: ['user is not enrolled'] }])
      end
    end
  end

  context '#list_courses' do
    let(:result) { CourseDomain.list_courses }

    context 'with empty courses list' do
      it 'returns empty array' do
        expect(result).to eq(Success([]))
      end
    end

    context 'with course without enrollments' do
      before { Course.create!(name: 'ABC') }

      it 'returns array with one element' do
        expect(result).to eq(Success([Course.last]))
      end

      it 'adds enrollments_count to the result' do
        course = result.value!.last
        expect(course.enrollments_count).to eq(0)
      end
    end

    context 'with multiple courses and enrollments' do
      before do
        c1 = Course.create!(name: 'c1')
        c2 = Course.create!(name: 'c2')
        c3 = Course.create!(name: 'c3')
        Course.create!(name: 'c4')

        u1 = User.create!(email: 'user1@example.com')
        u2 = User.create!(email: 'user2@example.com')
        u3 = User.create!(email: 'user3@example.com')

        u1.enrollments.create!(course: c1)
        u2.enrollments.create!(course: c1)
        u2.enrollments.create!(course: c2)
        u3.enrollments.create!(course: c2)
        u3.enrollments.create!(course: c3)
      end

      it 'returns correct enrollment counts' do
        courses = result.value!.map do |course|
          [course.name, course.enrollments_count]
        end.to_h
        expect(courses).to eq({
                                'c1' => 2,
                                'c2' => 2,
                                'c3' => 1,
                                'c4' => 0
                              })
      end
    end
  end

  describe '#list_by_user' do
    let(:email) { 'test@exampple.com' }
    let!(:user) { User.create!(email: email) }
    let(:course) { Course.create!(name: 'Ruby 101') }
    let(:result) { CourseDomain.list_by_user(user_id: user.id) }

    context 'with non-existing user' do
      let(:result) { CourseDomain.list_by_user(user_id: user.id + 1) }

      it 'returns failure' do
        expect(result).to eq(Failure([:failed, { base: ['user does not exist'] }]))
      end
    end

    context 'with no courses' do
      it 'returns empty array' do
        expect(result).to eq(Success([]))
      end
    end

    context 'with one course' do
      before do
        user.enrollments.create!(course: course)
      end

      it 'returns one course' do
        expect(result).to be_success
        expect(result.value!.length).to eq(1)
        expect(result.value!.first).to eq(course)
      end
    end

    context 'with many courses' do
      before do
        [course, Course.create!(name: 'Silly course'), Course.create!(name: 'TDD')].each do |crs|
          user.enrollments.create!(course: crs)
        end
      end

      it 'returns all of them' do
        expect(result).to be_success
        expect(result.value!.length).to eq(3)
      end

      it 'does not return courses user is not enrolled to' do
        additional = Course.create!(name: 'Not this one')
        expect(result).to be_success
        expect(result.value!.length).to eq(3)
        expect(result.value!.none? { |course| course == additional }).to eq(true)
      end
    end
  end
end

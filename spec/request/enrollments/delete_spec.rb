# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'DELETE /courses/:course_id/enrollments/:user_id' do
  include Rack::Test::Methods

  def app
    Rails.application
  end

  before do
    CourseDomain.enroll_user(user_id: user_id, course_id: course_id)
    before_request.call
    delete "/courses/#{course_id}/enrollments/#{user_id}", { 'CONTENT_TYPE' => 'application/json' }
  end

  let(:before_request) { proc {} }
  let(:json_response) { JSON.parse(last_response.body) }

  let(:course) { Course.create!(name: 'Ruby 101') }
  let(:course_id) { course.id }
  let(:user) { User.create!(email: 'test@example.com') }
  let(:user_id) { user.id }

  context 'success' do
    specify do
      expect(last_response.status).to eq(200)
      expect(json_response).to eq({ 'course_id' => course.id, 'user_id' => user.id })
    end
  end

  context 'non-existing course' do
    let(:course_id) { course.id + 10 }

    specify do
      expect(last_response.status).to eq(422)
      expect(json_response).to eq('course' => ['must exist'])
    end
  end

  context 'non-exist user' do
    let(:user_id) { user.id + 10 }

    specify do
      expect(last_response.status).to eq(422)
      # TODO is this ok?
      expect(json_response).to eq('base' => ['user is not enrolled'])
    end
  end

  context 'not enrolled' do
    let(:before_request) do
      -> { Enrollment.delete_all }
    end

    specify do
      expect(last_response.status).to eq(422)
      expect(json_response).to eq('base' => ['user is not enrolled'])
    end
  end
end

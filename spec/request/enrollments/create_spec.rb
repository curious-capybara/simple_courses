# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'POST /courses/:course_id/enrollments' do
  include Rack::Test::Methods

  def app
    Rails.application
  end

  before do
    before_request.call
    post "/courses/#{course_id}/enrollments", JSON.dump(params), { 'CONTENT_TYPE' => 'application/json' }
  end

  let(:before_request) { proc {} }
  let(:json_response) { JSON.parse(last_response.body) }
  let(:params) { Hash['user_id', user_id] }

  let(:course) { Course.create!(name: 'Ruby 101') }
  let(:course_id) { course.id }
  let(:user) { User.create!(email: 'test@example.com') }
  let(:user_id) { user.id }

  context 'success' do
    specify do
      expect(last_response.status).to eq(201)
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
      expect(json_response).to eq('user' => ['must exist'])
    end
  end

  context 'already enrolled' do
    let(:before_request) do
      -> { CourseDomain.enroll_user(course_id: course_id, user_id: user_id) }
    end

    specify do
      expect(last_response.status).to eq(422)
      expect(json_response).to eq('base' => ['user already enrolled'])
    end
  end
end

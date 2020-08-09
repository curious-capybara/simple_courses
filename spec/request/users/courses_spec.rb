# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GET /users/:id/courses' do
  include Rack::Test::Methods

  def app
    Rails.application
  end

  before do
    before_request.call
    get "/users/#{user_id}/courses", { 'CONTENT_TYPE' => 'application/json' }
  end

  let(:before_request) { proc {} }
  let(:json_response) { JSON.parse(last_response.body) }
  let!(:user) { User.create!(email: 'test@example.com') }
  let(:user_id) { user.id }

  context 'with no courses' do
    specify do
      expect(last_response.status).to eq(200)
      expect(json_response).to eq([])
    end
  end

  context 'with some courses' do
    let(:before_request) do
      -> {
        c1 = Course.create!(name: 'Ruby 101')
        c2 = Course.create!(name: 'JavaScript for dummies')
        c3 = Course.create!(name: 'Monads in the real world')

        u2 = User.create!(email: 'test2@example.com')

        CourseDomain.enroll_user(course_id: c1.id, user_id: user_id)
        CourseDomain.enroll_user(course_id: c3.id, user_id: user_id)
        CourseDomain.enroll_user(course_id: c2.id, user_id: u2.id)
      }
    end

    specify do
      expect(last_response.status).to eq(200)
      expect(json_response.length).to eq(2)
      expect(json_response.any?{ |c| c['name'] == 'JavaScript for dummies' }).to eq(false)
    end
  end

  context 'for non-existing user' do
    let(:user_id) { super() + 10 }

    specify do
      expect(last_response.status).to eq(422)
      expect(json_response).to eq('base' => ['user does not exist'])
    end
  end
end

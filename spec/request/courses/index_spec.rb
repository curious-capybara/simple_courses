# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GET /courses' do
  include Rack::Test::Methods

  def app
    Rails.application
  end

  before do
    before_request.call
    get '/courses', {}, { 'CONTENT_TYPE' => 'application/json' }
  end

  let(:before_request) { proc {} }
  let(:json_response) { JSON.parse(last_response.body) }

  context 'empty' do
    specify do
      expect(last_response.status).to eq(200)
      expect(json_response).to eq([])
    end
  end

  context 'with some courses' do
    let(:before_request) do
      proc {
        Course.create!(name: 'Ruby 101')
        Course.create!(name: 'JavaScript for dummies')
      }
    end

    specify do
      expect(last_response.status).to eq(200)
      expect(json_response.size).to eq(2)
      json_response.map do |course|
        expect(course['enrollments']).to eq(0)
      end
    end
  end

  context 'with some courses and enrollments' do
    let(:before_request) do
      proc {
        c1 = Course.create!(name: 'Ruby 101')
        c2 = Course.create!(name: 'JavaScript for dummies')

        u1 = User.create!(email: '1@example.com')
        u2 = User.create!(email: '2@example.com')

        c1.enrollments.create!(user: u1)
        c1.enrollments.create!(user: u2)
        c2.enrollments.create!(user: u1)
      }
    end

    specify do
      expect(last_response.status).to eq(200)
      expect(json_response.size).to eq(2)

      ruby_course = json_response.detect { |c| c['name'] == 'Ruby 101' }
      expect(ruby_course).not_to be_nil
      expect(ruby_course['enrollments']).to eq(2)

      other_course = json_response.detect { |c| c != ruby_course }
      expect(other_course['enrollments']).to eq(1)
    end
  end
end

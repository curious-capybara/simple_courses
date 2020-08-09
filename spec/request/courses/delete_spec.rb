# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'DELETE /courses/:id' do
  include Rack::Test::Methods

  def app
    Rails.application
  end

  before do
    delete "/courses/#{id}", { 'CONTENT_TYPE' => 'application/json' }
  end

  let(:json_response) { JSON.parse(last_response.body) }
  let(:course) { Course.create!(name: 'Ruby 101') }
  let(:id) { course.id }

  context 'success' do
    specify do
      expect(last_response.status).to eq(200)
      expect(json_response['name']).to eq('Ruby 101')
      expect(json_response['id']).to be_kind_of(Integer)
    end
  end

  context 'deleting non-existing course' do
    let(:id) { course.id + 10 }

    specify do
      expect(last_response.status).to eq(422)
      expect(json_response).to eq('base' => ['course does not exist'])
    end
  end
end

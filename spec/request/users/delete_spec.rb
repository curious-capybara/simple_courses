# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'DELETE /users/:id' do
  include Rack::Test::Methods

  def app
    Rails.application
  end

  before do
    delete "/users/#{id}", { 'CONTENT_TYPE' => 'application/json' }
  end

  let(:json_response) { JSON.parse(last_response.body) }
  let(:user) { User.create!(email: 'test@example.com') }
  let(:id) { user.id }

  context 'success' do
    specify do
      expect(last_response.status).to eq(200)
      expect(json_response['email']).to eq('test@example.com')
      expect(json_response['id']).to be_kind_of(Integer)
    end
  end

  context 'deleting non-existing user' do
    let(:id) { user.id + 10 }

    specify do
      expect(last_response.status).to eq(422)
      expect(json_response).to eq('base' => ['user does not exist'])
    end
  end
end

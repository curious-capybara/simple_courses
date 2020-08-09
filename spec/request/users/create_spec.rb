# frozen_string_literal: true

require 'rack/test'
require 'rails_helper'

RSpec.describe 'POST /users' do
  include Rack::Test::Methods

  def app
    Rails.application
  end

  before do
    before_request.call
    post '/users', JSON.dump(params), { 'CONTENT_TYPE' => 'application/json' }
  end

  let(:before_request) { proc {} }
  let(:json_response) { JSON.parse(last_response.body) }
  let(:params) { Hash['email', 'test@example.com'] }

  context 'success' do
    specify do
      expect(last_response.status).to eq(201)
      expect(json_response['email']).to eq('test@example.com')
      expect(json_response['id']).to be_kind_of(Integer)
    end
  end

  context 'email taken' do
    let(:before_request) do
      -> { User.create!(email: 'test@example.com') }
    end

    specify do
      expect(last_response.status).to eq(422)
      expect(json_response).to eq('email' => ['has already been taken'])
    end
  end

  context 'email blank' do
    let(:params) { super().merge('email' => '') }

    specify do
      expect(last_response.status).to eq(422)
      expect(json_response).to eq('email' => ["can't be blank"])
    end
  end
end

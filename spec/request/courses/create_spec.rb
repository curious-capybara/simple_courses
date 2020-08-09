require 'rails_helper'

RSpec.describe 'POST /courses' do
  include Rack::Test::Methods

  def app
    Rails.application
  end

  before do
    before_request.call
    post '/courses', JSON.dump(params), { 'CONTENT_TYPE' => 'application/json' }
  end

  let(:before_request) { proc {} }
  let(:json_response) { JSON.parse(last_response.body) }
  let(:params) { Hash['name', 'Ruby 101'] }

  context 'success' do
    specify do
      expect(last_response.status).to eq(201)
      expect(json_response['name']).to eq('Ruby 101')
      expect(json_response['id']).to be_kind_of(Integer)
    end
  end

  context 'name already taken' do
    let(:before_request) do
      -> { Course.create!(name: 'Ruby 101') }
    end

    specify do
      expect(last_response.status).to eq(201)
      expect(json_response['name']).to eq('Ruby 101')
    end
  end

  context 'name is blank' do
    let(:params) { Hash['name', ''] }

    specify do
      expect(last_response.status).to eq(422)
      expect(json_response).to eq('name' => ["can't be blank"])
    end
  end
end

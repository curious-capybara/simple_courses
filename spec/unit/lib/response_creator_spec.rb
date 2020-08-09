# frozen_string_literal: true

require 'spec_helper'
require 'response_creator'

RSpec.describe ResponseCreator do
  include Dry::Monads[:result]

  let(:value) { Object.new }
  let(:identity_serializer) { ->(obj) { obj } }
  let(:creator) { described_class.new(serializer: identity_serializer) }
  subject { creator.call(result) }

  context 'with Success' do
    let(:result) { Success(value) }

    it 'returns 200' do
      expect(subject.status_code).to eq(200)
    end

    it 'returns value' do
      expect(subject.message).to eq(value)
    end

    context 'with custom success code' do
      subject { creator.call(result, success_code: 201) }

      it 'returns 201' do
        expect(subject.status_code).to eq(201)
      end
    end
  end

  context 'with failed' do
    let(:result) { Failure([:failed, value]) }

    it 'returns 422' do
      expect(subject.status_code).to eq(422)
    end

    it 'returns value' do
      expect(subject.message).to eq(value)
    end
  end

  context 'with error' do
    let(:exception) { StandardError.new('test') }
    let(:result) { Failure([:error, exception]) }

    it 'returns 500' do
      expect(subject.status_code).to eq(500)
    end

    it 'returns generic message' do
      expect(subject.message).to eq('Internal server error')
    end
  end

  context 'with unknown failure type' do
    let(:result) { Failure([:oops, nil]) }

    it 'raises exception' do
      expect { subject }.to raise_error(RuntimeError)
    end
  end
end

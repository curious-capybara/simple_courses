# frozen_string_literal: true

require 'rails_helper'
require 'primitive_serializer'

RSpec.describe PrimitiveSerializer do
  subject { described_class.new.call(entity) }

  context 'course' do
    let(:entity) { Course.new(id: 1, name: 'Ruby 101') }

    it { is_expected.to eq({ name: 'Ruby 101', id: 1 }) }

    context 'with enrollments_count defined' do
      before do
        entity.define_singleton_method(:enrollments_count) { 3 }
      end

      it { is_expected.to eq({ name: 'Ruby 101', id: 1, enrollments: 3 }) }
    end
  end

  context 'user' do
    let(:entity) { User.new(id: 1, email: 'test@example.com') }

    it { is_expected.to eq({ email: 'test@example.com', id: 1 }) }
  end

  context 'array of coursed' do
    let(:course1_name) { 'Homeomorphic endofunctors mapping submanifolds of a Hilbert space' }
    let(:course2_name) { 'Monads in the real world' }
    let(:entity) do
      [
        Course.new(id: 1, name: course1_name),
        Course.new(id: 2, name: course2_name)
      ]
    end

    it do
      expected = [
        { id: 1, name: course1_name },
        { id: 2, name: course2_name }
      ]
      expect(subject).to match_array(expected)
    end
  end

  context 'unknown entity' do
    let(:entity) { Object.new }

    it do
      expect { subject }.to raise_error(RuntimeError)
    end
  end
end

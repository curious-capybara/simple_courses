# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserDomain do
  include Dry::Monads[:result]

  let(:email) { 'test@example.com' }

  describe '#create_user' do
    context 'with correct params' do
      let(:result) { UserDomain.create_user(email: email) }

      it 'creates a new user' do
        expect { result }.to change { User.count }.by(1)
      end

      it 'returns Success' do
        expect(result).to be_success
        expect(result.value!).to be_persisted
        expect(result.value!).to be_kind_of(User)
        expect(result.value!.email).to eq(email)
      end
    end

    context 'with duplicated email' do
      before { User.create!(email: email) }
      let(:result) { UserDomain.create_user(email: email) }

      it 'does not create a user with a duplicate email' do
        expect { result }.not_to change { User.count }
      end

      it 'returns failure' do
        expect(result).to be_failure
        expect(result.failure).to eq([:failed, { email: ['has already been taken'] }])
      end
    end

    context 'with empty email' do
      let(:result) { UserDomain.create_user(email: nil) }

      it 'does not create a user with empty email' do
        expect { result }.not_to change { User.count }
      end

      it 'returns failure' do
        expect(result).to be_failure
        expect(result.failure).to eq([:failed, { email: ["can't be blank"] }])
      end
    end
  end

  describe '#delete_user' do
    context 'when user exists' do
      let!(:user) { User.create!(email: email) }
      let(:result) { UserDomain.delete_user(id: user.id) }

      it 'deletes a user' do
        expect { result }.to change { User.count }.by(-1)
      end

      it 'does not delete other users' do
        other_email = 'test2@example.com'
        User.create!(email: other_email)
        result
        expect(User.find_by(email: other_email)).not_to eq(nil)
        expect(User.find_by(email: email)).to eq(nil)
      end

      it 'returns success' do
        expect(result).to be_success
      end
    end

    context 'when user does not exist' do
      let(:result) do
        last_id = User.order(:id).last&.id || 0
        UserDomain.delete_user(id: last_id + 1)
      end

      it 'returns failure' do
        expect(result).to be_failure
        expect(result.failure).to eq([:failed, { base: ['user does not exist'] }])
      end
    end
  end
end

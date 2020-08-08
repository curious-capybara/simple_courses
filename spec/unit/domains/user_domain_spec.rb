# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserDomain do
  let(:email) { 'test@example.com' }

  describe '#create_user' do
    it 'creates a new user' do
      expect { UserDomain.create_user(email: email) }.to change { User.count }.by(1)
    end

    it 'does not create a user with a duplicate email' do
      User.create!(email: email)
      expect { UserDomain.create_user(email: email) }.not_to change { User.count }
    end

    it 'does not create a user with empty email' do
      expect { UserDomain.create_user(email: nil) }.not_to change { User.count }
    end
  end

  describe '#delete_user' do
    let!(:user) { User.create!(email: email) }

    it 'deletes a user' do
      expect { UserDomain.delete_user(id: user.id) }.to change { User.count }.by(-1)
    end

    it 'does not delete other users' do
      other_email = 'test2@example.com'
      User.create!(email: other_email)
      UserDomain.delete_user(id: user.id)
      expect(User.find_by(email: other_email)).not_to eq(nil)
      expect(User.find_by(email: email)).to eq(nil)
    end
  end
end

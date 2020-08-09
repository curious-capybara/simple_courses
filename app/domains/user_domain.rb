# frozen_string_literal: true

require 'dry/monads'

module UserDomain
  extend Dry::Monads[:result]

  # Creates a new user
  #
  # @param email [String] email of a user to be created, must be unique
  def self.create_user(email:)
    user = User.new(email: email)
    if user.save
      Success(user)
    else
      Failure([:failed, user.errors.messages])
    end
  rescue StandardError => e
    Failure([:error, e])
  end

  # Deletes a user by their id
  #
  # @param id [Integer] user id
  def self.delete_user(id:)
    user = User.find_by(id: id)
    if user
      user.destroy
      Success(user)
    else
      Failure([:failed, { base: ['user does not exist'] }])
    end
  rescue StandardError => e
    Failure([:error, e])
  end

end

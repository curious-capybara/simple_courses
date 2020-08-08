module UserDomain
  # Creates a new user
  #
  # @param email [String] email of a user to be created, must be unique
  def self.create_user(email:)
    User.create(email: email)
  end

  # Deletes a user by their id
  #
  # @param id [Integer] user id
  def self.delete_user(id:)
    User.find_by(id: id)&.destroy
  end
end

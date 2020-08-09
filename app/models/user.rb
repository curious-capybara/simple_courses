# @private
class User < ApplicationRecord
  validates :email, uniqueness: true, presence: true

  has_many :enrollments
  has_many :courses, through: :enrollments
end

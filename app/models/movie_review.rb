class MovieReview < ApplicationRecord
  belongs_to :movie
  belongs_to :user

  validates :rating, presence: true,
                     numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 5 }
  validates :content, presence: true
  validates :movie_id, uniqueness: { scope: :user_id }
end

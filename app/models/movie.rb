class Movie < ApplicationRecord
  has_many :bookmarks, dependent: :destroy
  has_many :movie_reviews, dependent: :destroy

  validates :title, presence: true
  validates :overview, presence: true
  validates :tmdb_id, uniqueness: true, allow_nil: true
end

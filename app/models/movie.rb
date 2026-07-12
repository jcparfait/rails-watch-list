class Movie < ApplicationRecord
  has_many :bookmarks, dependent: :destroy

  validates :title, presence: true
  validates :overview, presence: true
  validates :tmdb_id, uniqueness: true, allow_nil: true
end

class List < ApplicationRecord
  belongs_to :user

  has_many :bookmarks, dependent: :destroy
  has_many :movies, through: :bookmarks
  has_many :reviews, dependent: :destroy

  has_one_attached :photo

  validates :name, presence: true, uniqueness: { scope: :user_id }
end
